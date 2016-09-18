require 'rubygems'
require 'git'
require 'fileutils'
require 'yajl'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'

class EngineBuilder < ErrorsApi

  require_relative 'builder_public.rb'
  require_relative 'blue_print_reader.rb'
  require_relative 'docker_file_builder/docker_file_builder.rb'
  require_relative 'build_report.rb'
  require_relative 'config_file_writer.rb'
  require_relative 'service_builder/service_builder.rb'

  require_relative 'builder/configure_services_backup.rb'
  include ConfigureServicesBackup
  require_relative 'builder/save_engine_configuration.rb'
  include SaveEngineConfiguration

  include BuildReport

  require_relative 'builder/engine_scripts_builder.rb'
  include EngineScriptsBuilder

  require_relative '../templater/templater.rb'

  attr_reader   :templater,
  :repoName,
  :build_name,
  :set_environments,
  :environments,
  :runtime,
  :web_port,
  :blueprint,
  :first_build,
  :memory,
  :result_mesg,
  :build_params,
  :data_uid,
  :data_gid,
  :build_error

  attr_accessor :app_is_persistent
  class BuildError < StandardError
    attr_reader :parent_exception, :method_name
    def initialize(parent)
      @container=nil
      @parent_exception = parent
    end
  end

  def initialize(params, core_api)
    # {:engine_name=>'phpmyadmin5', :host_name=>'phpmyadmin5', :domain_name=>'engines.demo', :http_protocol=>'HTTPS and HTTP', :memory=>'96', :variables=>{}, :attached_services=>[{:publisher_namespace=>'EnginesSystem', :type_path=>'filesystem/local/filesystem', :create_type=>'active', :parent_engine=>'phpmyadmin4', :service_handle=>'phpmyadmin4'}, {:publisher_namespace=>'EnginesSystem', :type_path=>'database/sql/mysql', :create_type=>'active', :parent_engine=>'phpmyadmin4', :service_handle=>'phpmyadmin4'}], :repository_url=>'https://github.com/EnginesBlueprints/phpmyadmin.git'}

    #@core_api = core_api.dup WTF !
    @core_api = core_api
    @mc = nil # Used in clean up only
    @build_params = params
    return log_error_mesg('empty container name', params) if @build_params[:engine_name].nil? || @build_params[:engine_name] == ''
    @build_params[:engine_name].freeze
    @build_name = File.basename(@build_params[:repository_url]).sub(/\.git$/, '')
    @web_port = SystemConfig.default_webport
    @memory = @build_params[:memory]
    @app_is_persistent = false
    @result_mesg = 'Aborted Due to Errors'
    @first_build = true
    @attached_services = []
    return "error" unless create_templater
    return "error" unless process_supplied_envs(params[:variables])
    @runtime =  ''
    return "error" unless create_build_dir
    return "error" unless setup_log_output
    @rebuild = false
    @data_uid = '11111'
    @data_gid = '11111'
    @build_params[:data_uid] =  @data_uid
    @build_params[:data_gid] = @data_gid
    SystemDebug.debug(SystemDebug.builder, :builder_init, params,@build_params)
    @service_builder = ServiceBuilder.new(@core_api, @templater, @build_params[:engine_name],  @attached_services)
    SystemDebug.debug(SystemDebug.builder, :builder_init__service_builder, params,@build_params)
  rescue StandardError => e
    log_exception(e)
  end

  def volumes
    return @service_builder.volumes
  end

  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    return log_error_mesg('Failed to Backup Last build', self) unless backup_lastbuild
    return log_error_mesg('Failed to setup rebuild', self) unless setup_rebuild
    return build_container
  end

  def build_failed(errmesg)
    @build_params[:error_mesg] = errmesg
    SystemStatus.build_failed(@build_params)
    log_build_errors(errmesg)
    @result_mesg = 'Error.' + errmesg
    post_failed_build_clean_up
  end

  def build_container
    SystemDebug.debug(SystemDebug.builder,  ' Starting build with params ',  @build_params)
    log_build_output('Checking Free space')
    space = @core_api.system_image_free_space
    return build_failed('Failed to determine free space ') if space.is_a?(EnginesError)
    space /= 1024
    SystemDebug.debug(SystemDebug.builder,  ' free space /var/lib/docker only ' + space.to_s + 'MB')
    return build_failed('Not enough free space /var/lib/docker only ' + space.to_s + 'MB') if space < SystemConfig.MinimumFreeImageSpace  && space != -1
    log_build_output(space.to_s + 'MB free > ' +  SystemConfig.MinimumFreeImageSpace.to_s + ' required')

    free_ram = @core_api.available_ram
    if @build_params[:memory].to_i < SystemConfig.MinimumBuildRam
      ram_needed = SystemConfig.MinimumBuildRam
    else
      ram_needed = @build_params[:memory].to_i
    end
    return build_failed('Not enough free only ' + free_ram.to_s + "MB free " + ram_needed.to_s + 'MB required' ) if free_ram < ram_needed
    log_build_output(free_ram.to_s + 'MB free > ' + ram_needed.to_s + 'MB required')

    log_build_output('Reading Blueprint')
    @blueprint = load_blueprint
    return close_all if @blueprint.nil? || @blueprint == false
    @blueprint_reader = BluePrintReader.new(@build_params[:engine_name], @blueprint, self)
    return close_all unless @blueprint_reader.process_blueprint
    return close_all unless setup_default_files
    return close_all unless ConfigFileWriter.compile_base_docker_files(@templater, basedir)
    unless @blueprint_reader.web_port.nil?
      @web_port = @blueprint_reader.web_port
    else
      read_web_port
    end
    read_web_user

    @build_params[:mapped_ports] =  @blueprint_reader.mapped_ports
    SystemDebug.debug(SystemDebug.builder,   :ports, @build_params[:mapped_ports])
    SystemDebug.debug(SystemDebug.builder,   :attached_services, @build_params[:attached_services])
    return build_failed(@service_builder.last_error) unless @service_builder.required_services_are_running?

    return build_failed(@service_builder.last_error) if @service_builder.create_persistent_services(@blueprint_reader.services, @blueprint_reader.environments,@build_params[:attached_services]).is_a?(EnginesError)

    apply_templates_to_environments
    create_engines_config_files
    index = 0
    @blueprint_reader.sed_strings[:sed_str].each do |sed_string|
      sed_string = @templater.process_templated_string(sed_string)
      @blueprint_reader.sed_strings[:sed_str][index] = sed_string
      index += 1
    end
    @build_params[:app_is_persistent] = @service_builder.app_is_persistent
    dockerfile_builder = DockerFileBuilder.new(@blueprint_reader, @build_params, @web_port, self)
    return post_failed_build_clean_up unless dockerfile_builder.write_files_for_docker

    write_env_file

    setup_framework_logging

    base_image_name = read_base_image_from_dockerfile

    if base_image_name.nil?
      log_build_errors('Failed to Read Image from Dockerfile')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    end
    log_build_output('Pull base Image')
    if @core_api.pull_image(base_image_name) == false
      log_build_errors('Failed Pull Image:' + base_image_name + ' from  DockerHub')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    end
    SystemUtils.run_system('/opt/engines/system/scripts/system/create_container_dir.sh ' + @build_params[:engine_name])
    if build_init == false
      log_build_errors('Error Build Image failed')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    else
      if @core_api.image_exist?(@build_params[:engine_name]) == false
        log_build_errors('Built Image not found')
        @last_error = ' ' + tail_of_build_log
        return post_failed_build_clean_up
      end
      log_build_output('Creating Deploy Image')
      mc = create_managed_container
      if mc == false
        log_build_errors('Failed to create Managed Container')
        return post_failed_build_clean_up
      end
      @service_builder.create_non_persistent_services(@blueprint_reader.services)
    end
    @service_builder.release_orphans
    @result_mesg = 'Build Successful'
    log_build_output('Build Successful')
    @container = mc
    build_report = generate_build_report(@templater, @blueprint)
    @core_api.save_build_report(@container, build_report)
    cnt = 0
    lcnt = 5
    log_build_output('Starting Engine')
    while mc.is_startup_complete? == false && mc.is_running?
      cnt += 1
      if cnt == 120
        log_build_output('') # force EOL to end the ...
        log_build_output('Startup still running')
        break
      end
      if lcnt == 5
        add_to_build_output('.')
        lcnt = 0
      else
        lcnt += 1
      end
      sleep 1
    end
    log_build_output('') # force EOL to end the ...
    if mc.is_running? == false
      
      log_build_output('Engine Stopped:' + mc.logs_container.to_s)
      @result_mesg = 'Engine Stopped! ' + mc.logs_container.to_s
    end

    close_all
  SystemStatus.build_complete(build_params)
    return mc
  rescue StandardError => e
    log_exception(e)
    post_failed_build_clean_up
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
    close_all
  end

  def setup_framework_logging
    log_build_output('Seting up logging')
    rmt_log_dir_var_fname = basedir + '/home/LOG_DIR'
    if File.exist?(rmt_log_dir_var_fname)
      rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
      rmt_log_dir = rmt_log_dir_varfile.read
    else
      rmt_log_dir = '/var/log'
    end
    local_log_dir = SystemConfig.SystemLogRoot + '/containers/' + @build_params[:engine_name]
    Dir.mkdir(local_log_dir) unless Dir.exist?(local_log_dir)
    return ' -v ' + local_log_dir + ':' + rmt_log_dir + ':rw '
  rescue StandardError => e
    log_exception(e)
  end

  def backup_lastbuild
    dir = basedir
    backup = dir + '.backup'
    FileUtils.rm_rf(backup) if Dir.exist?(backup)
    FileUtils.mv(dir, backup) if Dir.exist?(dir)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def load_blueprint
    log_build_output('Reading Blueprint')
    json_hash = BlueprintApi.load_blueprint_file(basedir + '/blueprint.json')
    return SystemUtils.symbolize_keys(json_hash)
  rescue StandardError => e
    log_exception(e)
  end

  def clone_repo
    log_build_output('Clone Blueprint Repository')
    g = Git.clone(@build_params[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
  rescue StandardError => e
    log_error_mesg('Problem cloning Git', g)
    log_exception(e)
  end

  def setup_default_files
    log_build_output('Setup Default Files')
    log_error_mesg('Failed to setup Global Defaults', self) unless setup_global_defaults
    return setup_framework_defaults
  end

  def build_init
    log_build_output('Building Image')
    create_build_tar
    log_build_output('Cancelable:true')
    res = @core_api.docker_build_engine(@build_params[:engine_name], SystemConfig.DeploymentDir + '/' + @build_name.to_s + '.tgz', self)

    log_build_output('Cancelable:false')
    return true if res
    log_error_mesg('build Image failed ', res)
  rescue StandardError => e
    log_exception(e)
  end

  def create_build_tar
    dest_file = SystemConfig.DeploymentDir + '/' + @build_name.to_s + '.tgz'
    cmd = ' cd ' + basedir + ' ; tar -czf ' + dest_file + ' .'
    run_system(cmd)
  end

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    mc = managed_container.create_container
    return log_error_mesg('Failed to Launch ', mc) if mc.is_a?(EnginesError)
    save_engine_built_configuration(managed_container)
    return mc
  rescue StandardError => e
    log_exception(e)
  end

  def setup_global_defaults
    log_build_output('Setup global defaults')
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates  + '/global/* ' + basedir
    system cmd
  rescue StandardError => e
    log_exception(e)
  end

  def setup_framework_defaults
    log_build_output('Copy in default templates')
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework + '/* ' + basedir
    system cmd
  rescue StandardError => e
    log_exception(e)
  end

  def get_blueprint_from_repo
    log_build_output('Backup last build')
    return log_error_mesg('Failed to Backup Last build', self) unless backup_lastbuild
    log_build_output('Cloning Blueprint')
    clone_repo
  end

  def build_from_blue_print
    return log_error_mesg('Failed backup last build',self) unless backup_lastbuild
    return log_error_mesg('Failed to Load Blue print',self) unless get_blueprint_from_repo
    build_container
  end

  def read_web_port
    log_build_output('Setting Web port')
    stef = File.open(basedir + '/home/stack.env', 'r')
    while line = stef.gets do
      if line.include?('PORT')
        i = line.split('=')
        @web_port = i[1].strip
        SystemDebug.debug(SystemDebug.builder,   :web_port_line, line)
      end
    end
  rescue StandardError => e
    log_exception(e)
    #      throw BuildStandardError.new(e,'setting web port')
  end

  def read_web_user
    log_build_output('Read Web User')
    stef = File.open(basedir + '/home/stack.env', 'r')
    while line = stef.gets do
      if line.include?('USER')
        i = line.split('=')
        @web_user = i[1].strip
      end
    end
  rescue StandardError => e
    log_exception(e)
  end

  def apply_templates_to_environments
    @blueprint_reader.environments.each do |env|
      env.value = @templater.process_templated_string(env.value)
    end
  end

  def post_failed_build_clean_up
    return close_all if @rebuild
    # remove containers
    # remove persistent services (if created/new)
    # deregister non persistent services (if created)
    # FIXME: need to re orphan here if using an orphan Well this should happen on the fresh
    # FIXME: don't delete shared service
    SystemDebug.debug(SystemDebug.builder, :Clean_up_Failed_build)
    # FIXME: Stop it if started (ie vol builder failure)
    # FIXME: REmove container if created
    unless @build_params[:reinstall].is_a?(TrueClass)
      if @mc.is_a?(ManagedContainer)
        @mc.stop_container if @mc.is_running?
        @mc.destroy_container if @mc.has_container?
        @mc.delete_image if @mc.has_image?
      end

      return log_error_mesg('Failed to remove ' + @service_builder.last_error.to_s ,self) unless @service_builder.service_roll_back
      return log_error_mesg('Failed to remove ' + @core_api.last_error.to_s ,self) unless @core_api.remove_engine(@build_params[:engine_name])
    end

    #    params = {}
    #    params[:engine_name] = @build_name
    #    @core_api.delete_engine(params) # remove engine if created, removes from manged_engines tree (main reason to call)
    @result_mesg = @result_mesg.to_s + ' Roll Back Complete'
    SystemDebug.debug(SystemDebug.builder,'Roll Back Complete')
    close_all
    return false
  end

  def create_engines_config_files
    create_template_files
    create_php_ini
    create_apache_config
    create_scripts
  end

  def create_template_files
    if @blueprint[:software].key?(:template_files) && @blueprint[:software][:template_files].nil? == false
      @blueprint[:software][:template_files].each do |template_hash|
        template_hash[:path].sub!(/^\/home/,'')
        write_software_file('/home/engines/templates/' + template_hash[:path], template_hash[:content])
      end
    end
  end

  def create_httaccess
    if @blueprint[:software].key?(:apache_htaccess_files) && @blueprint[:software][:apache_htaccess_files].nil? == false
      @blueprint[:software][:apache_htaccess_files].each do |htaccess_hash|
        write_software_file('/home/engines/htaccess_files' + htaccess_hash[:directory] + '/.htaccess', htaccess_hash[:htaccess_content])
      end
    end
  end

  def create_php_ini
    FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomPHPiniFile))
    if @blueprint[:software].key?(:custom_php_inis) \
    && @blueprint[:software][:custom_php_inis].nil? == false \
    && @blueprint[:software][:custom_php_inis].length > 0
      contents = ''
      @blueprint[:software][:custom_php_inis].each do |php_ini_hash|
        content = php_ini_hash[:content].gsub(/\r/, '')
        contents = contents + "\n" + content
      end
      write_software_file(SystemConfig.CustomPHPiniFile, contents)
    end
  end

  def create_apache_config
    if @blueprint[:software].key?(:apache_httpd_configurations) \
    && @blueprint[:software][:apache_httpd_configurations].nil? == false \
    && @blueprint[:software][:apache_httpd_configurations].length > 0
      FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomApacheConfFile))
      #  @ if @blueprint[:software].key?(:apache_httpd_configurations) && @blueprint[:software][:apache_httpd_configurations]  != nil
      contents = ''
      @blueprint[:software][:apache_httpd_configurations].each do |httpd_configuration|
        contents = contents + httpd_configuration[:httpd_configuration] + "\n"

      end
      write_software_file(SystemConfig.CustomApacheConfFile, contents)
    end
  end

  def tail_of_build_log
    retval = ''
    lines = File.readlines(SystemConfig.DeploymentDir + '/build.out')
    lines_count = lines.count - 1
    start = lines_count - 10
    for n in start..lines_count
      retval += lines[n].to_s
    end
    return retval
  end

  def setup_rebuild
    log_build_output('Setting up rebuild')
    FileUtils.mkdir_p(basedir)
    blueprint = @core_api.load_blueprint(@engine)
    statefile = basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  rescue StandardError => e
    log_exception(e)
    close_all
  end

  #app_is_persistent

  def running_logs()
    return @container.logs_container unless @container.nil?
    return nil
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    @build_params[:web_port] = @web_port
    @build_params[:volumes] = @service_builder.volumes
    @build_params[:image] = @build_params[:engine_name]
    @mc = ManagedEngine.new(@build_params, @blueprint_reader, @core_api.container_api)
    @mc.save_state # no running.yaml throws a no such container so save so others can use
    log_build_errors('Failed to save blueprint ' + @blueprint.to_s) unless @mc.save_blueprint(@blueprint)
    log_build_output('Launching ' + @mc.to_s)
    @core_api.init_engine_dirs(@mc)
    return log_build_errors('Error Failed to Launch') unless launch_deploy(@mc)

    log_build_output('Applying Volume settings and Log Permissions' + @mc.to_s)
    return log_build_errors('Error Failed to Apply FS' + @mc.to_s) unless @service_builder.run_volume_builder(@mc, @web_user)
    flag_restart_required(@mc) if @has_post_install == true
    return @mc
  rescue StandardError => e
    log_exception(e)
  end

  def engine_environment
    return @blueprint_reader.environments
  end

  def flag_restart_required(mc)
    restart_reason='Restart to run post install script, as required in blueprint'
    # FixME this should be elsewhere
    restart_flag_file = ContainerStateFiles.restart_flag_file(mc)
    FileUtils.mkdir_p(ContainerStateFiles.container_flag_dir(mc)) unless Dir.exist?(ContainerStateFiles.container_flag_dir(mc))
    f = File.new(restart_flag_file,'w+')
    f.puts(restart_reason)
    f.close
    File.chmod(0660,restart_flag_file)
    FileUtils.chown(nil,'containers',restart_flag_file)
  end

  def log_error_mesg(m,o)
    log_build_errors(m.to_s + o.to_s)
    super
  end

  def get_build_log_stream
    @log_pipe_rd
  end

  def get_build_err_stream
    @error_pipe_rd
  end

  def add_to_build_output(word)
    @log_file.write(word)
    @log_file.flush
    # @log_pipe_wr.puts(line)
  rescue
    return
  end

  def abort_build
    post_failed_build_clean_up
    return true
  end

  def log_build_output(line)
    return if line == "\u0000"
    @log_file.puts(line)
    @log_file.flush
    # @log_pipe_wr.puts(line)
  rescue
    return
  end

  def log_build_errors(line)
    line = '' if line.nil?
    @err_file.puts(line.to_s) unless @err_file.nil?
    log_build_output('ERROR:' + line.to_s)
    @result_mesg = 'Error. Aborted Due to:' + line.to_s
    @build_error = @result_mesg
    return false
  end

  def basedir
    SystemConfig.DeploymentDir + '/' + @build_name.to_s
  end

  private

  def process_supplied_envs(custom_env)
    SystemDebug.debug(SystemDebug.builder,  :custom_env, custom_env)
    if custom_env.nil?
      @set_environments = {}
      @environments = []
    elsif custom_env.instance_of?(Array)
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      # FIXME: need to vet all environment variables
      @set_environments = {}
    else
      custom_env_hash = custom_env
      SystemDebug.debug(SystemDebug.builder,   :Merged_custom_env, custom_env_hash)
      @set_environments = custom_env_hash
      @environments = []
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def create_build_dir
    FileUtils.mkdir_p(basedir)
  rescue StandardError => e
    log_exception(e)
  end

  def close_all
    if @log_file.closed? == false
      log_build_output('Build Result:' + @result_mesg)
      log_build_output('Build Finished')
      @log_file.close
    end
    if@err_file.closed? == false
      @err_file.close
    end
    if @log_pipe_wr.closed? == false
      @log_pipe_wr.close
    end
    if @error_pipe_wr.closed? == false
      @error_pipe_wr.close
    end
    return false
  end

  def create_templater
    builder_public = BuilderPublic.new(self)
 
    @templater = Templater.new(@core_api.system_value_access, builder_public)
  rescue StandardError => e
    log_exception(e)
  end

  protected

  #
  def debug(fld)
    puts 'ERROR: '
    p fld
  end

  def read_base_image_from_dockerfile

    dockerfile = File.open(basedir + '/Dockerfile', 'r')
    from_line = dockerfile.gets("\n", 100)
    from_line.gsub(/^FROM[ ]./, '')
  rescue StandardError => e
    log_build_errors(e)
    return nil
  end

  require 'open3'

  def run_system(cmd)
    log_build_output('Running ' + cmd)
    res = ''
    oline = ''
    error_mesg = ''
    begin
      Open3.popen3(cmd) do |_stdin, stdout, stderr, _th|
        oline = ''
        stderr_is_open = true
        begin
          stdout.each { |line|
            #  print line
            line = line.gsub(/\\\'/, '')
            res += line.chop
            oline = line
            log_build_output(line)
            if stderr_is_open
              err = stderr.read_nonblock(1000)
              error_mesg += err
              log_build_errors(err)
            end
          }
        rescue Errno::EIO
          res += oline.chop
          log_build_output(oline)
          if stderr_is_open
            err = stderr.read_nonblock(1000)
            error_mesg += err
            log_build_errors(err)
            p :EIO_retry
            retry
          end
        rescue IO::WaitReadable
          # p :wait_readable_retrt
          retry
        rescue EOFError
          if stdout.closed? == false
            stderr_is_open = false
            p :EOF_retry
            retry
          elsif stderr.closed? == true
            # log_build_errors(error_mesg)
            return true
          else
            err = stderr.read_nonblock(1000)
            error_mesg += err
            log_build_errors(err)
          end
        end
      end
      if error_mesg.length > 2 # error_mesg.include?('Error:') || error_mesg.include?('FATA')
        log_build_errors(error_mesg)
        log_error_mesg(error_mesg, self)
      end
      SystemDebug.debug(SystemDebug.builder,   :build_suceeded)
      return true
    end
  end

  def write_env_file
    log_build_output('Setting up Environments')
    env_file = File.new(basedir + '/home/app.env', 'a')
    env_file.puts('')
    @blueprint_reader.environments.each do |env|
      env_file.puts(env.name) unless env.build_time_only
    end
    @set_environments.each do |env|
      env_file.puts(env[0])
    end
    env_file.close
  end

  def write_software_file(filename, content)
    ConfigFileWriter.write_templated_file(@templater, basedir + '/' + filename, content)
  end

  def setup_log_output
    @log_file = File.new(SystemConfig.DeploymentDir + '/build.out', File::CREAT | File::TRUNC | File::RDWR, 0644)
    @err_file = File.new(SystemConfig.DeploymentDir + '/build.err', File::CREAT | File::TRUNC | File::RDWR, 0644)
    @log_pipe_rd, @log_pipe_wr = IO.pipe
    @error_pipe_rd, @error_pipe_wr = IO.pipe
  rescue StandardError => e
    log_exception(e)
  end

  def log_exception(e)
    log_build_errors(e.to_s)
    close_all
    super
  end
end
