require 'rubygems'
require 'git'
require 'fileutils'
require 'json'

class EngineBuilder < ErrorsApi
  require '/opt/engines/lib/ruby/api/system/errors_api.rb'
  require_relative 'builder_public.rb'
  require_relative 'blue_print_reader.rb'
  require_relative 'docker_file_builder.rb'
  require_relative 'build_report.rb'
  include BuildReport

  require_relative '../templater/templater.rb'

  @repo_name = nil
  @hostname = nil
  @domain_name = nil
  @build_name = nil
  @http_protocol = 'HTTPS and HTTP'

  attr_reader   :templater,
  :repoName,
  :hostname,
  :build_name,
  :set_environments,
  :container_name,
  :environments,
  :domain_name,
  :runtime,
  :web_port,
  :http_protocol,
  :blueprint,
  :first_build,
  :memory,
  :result_mesg

  attr_accessor :app_is_persistant
  class BuildError < StandardError
    attr_reader :parent_exception, :method_name
    def initialize(parent)
      @parent_exception = parent
    end
  end

  def initialize(params, core_api)
    # {:engine_name=>'phpmyadmin5', :host_name=>'phpmyadmin5', :domain_name=>'engines.demo', :http_protocol=>'HTTPS and HTTP', :memory=>'96', :variables=>{}, :attached_services=>[{:publisher_namespace=>'EnginesSystem', :type_path=>'filesystem/local/filesystem', :create_type=>'active', :parent_engine=>'phpmyadmin4', :service_handle=>'phpmyadmin4'}, {:publisher_namespace=>'EnginesSystem', :type_path=>'database/sql/mysql', :create_type=>'active', :parent_engine=>'phpmyadmin4', :service_handle=>'phpmyadmin4'}], :repository_url=>'https://github.com/EnginesBlueprints/phpmyadmin.git'}
    @core_api = core_api
    params[:engine_name].gsub!(/ /, '_')
    @container_name = params[:engine_name]
    @domain_name = params[:domain_name]
    @hostname = params[:host_name]
    @http_protocol = params[:http_protocol]
    @memory = params[:memory]
    @repo_name = params[:repository_url]
    return log_error_mesg('empty container name', params) if @container_name.nil? || @container_name == ''    
    @container_name.freeze
    @build_name = File.basename(@repo_name).sub(/\.git$/, '')
    @web_port = SystemConfig.default_webport
    @app_is_persistant = false
    @result_mesg = 'Aborted Due to Errors'
    @first_build = true
    @attached_services = []
    return "error" unless create_templater
    return "error" unless process_supplied_envs(params[:variables])
    @runtime =  ''
    return "error" unless create_build_dir
    return "error" unless setup_log_output
  rescue StandardError => e
    log_exception(e)
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

  def log_build_output(line)
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
    @result_mesg = 'Aborted Due to:' + line.to_s
    
    return false
  end

  def setup_framework_logging
    rmt_log_dir_var_fname = get_basedir + '/home/LOG_DIR'
    if File.exist?(rmt_log_dir_var_fname)
      rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
      rmt_log_dir = rmt_log_dir_varfile.read
    else
      rmt_log_dir = '/var/log'
    end
    local_log_dir = SystemConfig.SystemLogRoot + '/containers/' + @container_name
    Dir.mkdir(local_log_dir) unless Dir.exist?(local_log_dir)     
    return ' -v ' + local_log_dir + ':' + rmt_log_dir + ':rw '
  rescue StandardError => e
    log_exception(e)
  end

  def backup_lastbuild
    dir = get_basedir   
    backup = dir + '.backup'
    FileUtils.rm_rf(backup) if Dir.exist?(backup)
    FileUtils.mv(dir, backup) if Dir.exist?(dir)  
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def load_blueprint
    log_build_output('Reading Blueprint')
    blueprint_file_name = get_basedir + '/blueprint.json'
    blueprint_file = File.open(blueprint_file_name, 'r')
    blueprint_json_str = blueprint_file.read
    blueprint_file.close
    json_hash = JSON.parse(blueprint_json_str)
    p :symbolized_hash
    hash = SystemUtils.symbolize_keys(json_hash)
    return hash
  rescue StandardError => e
    log_exception(e)
  end

  def clone_repo
    log_build_output('Clone Blueprint Repository')
    g = Git.clone(@repo_name, @build_name, :path => SystemConfig.DeploymentDir)
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
    cmd = '/usr/bin/docker build --force-rm=true --tag=' + @container_name + ' ' + get_basedir
    res = run_system(cmd)
    return true if res
    log_error_mesg('build init failed ', res)
  rescue StandardError => e
    log_exception(e)
  end

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    return true if managed_container.create_container
    log_build_errors('Failed to Launch')
  rescue StandardError => e
    log_exception(e)
  end

  def setup_global_defaults
    log_build_output('Setup global defaults')
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates + '/global/* ' + get_basedir
    system cmd
  rescue StandardError => e
    log_exception(e)
  end

  def setup_framework_defaults
    log_build_output('Copy in default templates')
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework + '/* ' + get_basedir
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
    return log_error_mesg('Failed to Load Blue print',self) unless get_blueprint_from_repo
    build_container
  end

  def read_web_port
    log_build_output('Setting Web port')
    stef = File.open(get_basedir + '/home/stack.env', 'r')
    while line = stef.gets do
      if line.include?('PORT')
        i = line.split('=')
        @web_port = i[1].strip
        p :web_port_line
        p line
      end
      p @web_port
      puts(@web_port)
    end
  rescue StandardError => e
    log_exception(e)
    #      throw BuildStandardError.new(e,'setting web port')
  end

  def read_web_user
    log_build_output('Read Web User')
    stef = File.open(get_basedir + '/home/stack.env', 'r')
    while line = stef.gets do
      if line.include?('USER')
        i = line.split('=')
        @web_user = i[1].strip
      end
    end
  rescue StandardError => e
    log_exception(e)
  end

  def data_gid
    return @blueprint_reader.data_gid
  end

  def rebuild_managed_container(engine)
     @engine = engine
     log_build_output('Starting Rebuild')
    return log_error_mesg('Failed to Backup Last build', self) unless backup_lastbuild
    return log_error_mesg('Failed to setup rebuild', self) unless setup_rebuild
    return build_container
   end
   
  def build_container
    log_build_output('Reading Blueprint')
    @blueprint = load_blueprint
   return close_all if @blueprint.nil? || @blueprint == false
    @blueprint_reader = BluePrintReader.new(@build_name, @container_name, @blueprint, self)
    return close_all if @blueprint_reader.process_blueprint == false
    return close_all if setup_default_files == false
    return close_all if compile_base_docker_files == false
    if @blueprint_reader.web_port.nil? == false
      @web_port = @blueprint_reader.web_port
    else
      read_web_port
    end
    read_web_user
    return post_failed_build_clean_up unless create_persistant_services
    @blueprint_reader.environments.each do |env|
      p :env_before
      p env.value
      env.value = @templater.process_templated_string(env.value)
      p :env_after
      p env.value
    end
    # fill_service_environment_variables
    create_template_files
    create_php_ini
    create_apache_config
    create_scripts
    index = 0
    @blueprint_reader.sed_strings[:sed_str].each do |sed_string|
      sed_string = @templater.process_templated_string(sed_string)
      @blueprint_reader.sed_strings[:sed_str][index] = sed_string
      index += 1
    end
    dockerfile_builder = DockerFileBuilder.new(@blueprint_reader, @container_name, @hostname, @domain_name, @web_port, self)
    return post_failed_build_clean_up unless dockerfile_builder.write_files_for_docker
  log_build_output('Setingup Environments')
    env_file = File.new(get_basedir + '/home/app.env', 'a')
    env_file.puts('')
    @blueprint_reader.environments.each do |env|
      env_file.puts(env.name) unless env.build_time_only
    end
    @set_environments.each do |env|
      env_file.puts(env[0])
    end
    env_file.close
    log_build_output('Setingup logging')
    setup_framework_logging
    
    base_image_name = read_base_image_from_dockerfile
    
    if base_image_name.nil? 
      p :From_image_not_found_inD
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
    if build_init == false
      log_build_errors('Error Build Image failed')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    else
      if @core_api.image_exist?(@container_name) == false
        p :image_not_found
        @last_error = ' ' + tail_of_build_log
        return post_failed_build_clean_up
      end
      log_build_output('Creating Deploy Image')
      mc = create_managed_container
      if mc.nil? == false
        create_non_persistant_services
      else
        return post_failed_build_clean_up
      end
    end
    @result_mesg = 'Build Successful'
    log_build_output('Build Successful')
    build_report = generate_build_report(@blueprint)
    @core_api.save_build_report(mc, build_report)
    #      p :build_report
    #      p build_report
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
      log_build_output('Engine Stopped')
      @result_mesg = 'Engine Stopped!'
    end
    close_all
    return mc
  rescue StandardError => e
    log_exception(e)
    post_failed_build_clean_up
    close_all
ensure
  File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
  end

  def post_failed_build_clean_up
    # remove containers
    # remove persistant services (if created/new)
    # deregister non persistant services (if created)
    # FIXME: need to re orphan here if using an orphan Well this should happen on the fresh
    # FIXME: don't delete shared service
    p :Clean_up_Failed_build
    @blueprint_reader.services.each do |service_hash|
      if service_hash[:fresh]
        service_hash[:remove_all_data] = true
        @core_api.dettach_service(service_hash) # true is delete persistant
      end
    end
    return log_error_mesg("Failed to remove", @last_error,self) unless @core_api.remove_engine(@build_name)
#    params = {}
#    params[:engine_name] = @build_name
#    @core_api.delete_engine(params) # remove engine if created, removes from manged_engines tree (main reason to call)
    @result_mesg = @result_mesg.to_s + ' Roll Back Complete'
    close_all
  end

  def create_template_files
    if @blueprint[:software].key?(:template_files) && @blueprint[:software][:template_files].nil? == false
      @blueprint[:software][:template_files].each do |template_hash|
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

  def create_scripts
    FileUtils.mkdir_p(get_basedir + SystemConfig.ScriptsDir)
    create_start_script
    create_install_script
    create_post_install_script
  end

  def create_start_script
    if @blueprint[:software].key?(:custom_start_script) \
    && @blueprint[:software][:custom_start_script].nil? == false\
    && @blueprint[:software][:custom_start_script].length > 0
      content = @blueprint[:software][:custom_start_script].gsub(/\r/, '')
      write_software_file(SystemConfig.StartScript, content)
      File.chmod(0755, get_basedir + SystemConfig.StartScript)
    end
  end

  def create_install_script
    if @blueprint[:software].key?(:custom_install_script) \
    && @blueprint[:software][:custom_install_script].nil? == false\
    && @blueprint[:software][:custom_install_script].length > 0
      content = @blueprint[:software][:custom_install_script].gsub(/\r/, '')
      write_software_file(SystemConfig.InstallScript, content)
      p :create_install_script
      File.chmod(0755, get_basedir + SystemConfig.InstallScript)
    end
  end

  def create_post_install_script
    if @blueprint[:software].key?(:custom_post_install_script) \
    && @blueprint[:software][:custom_post_install_script].nil? == false \
    && @blueprint[:software][:custom_post_install_script].length > 0
      content = @blueprint[:software][:custom_post_install_script].gsub(/\r/, '')
      write_software_file(SystemConfig.PostInstallScript, content)
      #        post_install_script_file = File.open(get_basedir + SystemConfig.PostInstallScript,'wb', :crlf_newline => false)
      #      post_install_script_file.puts(content)
      #      post_install_script_file.close
      File.chmod(0755, get_basedir + SystemConfig.PostInstallScript)
    end
  end

  def create_php_ini
    FileUtils.mkdir_p(get_basedir + File.dirname(SystemConfig.CustomPHPiniFile))
    if @blueprint[:software].key?(:custom_php_inis) \
    && @blueprint[:software][:custom_php_inis].nil? == false \
    && @blueprint[:software][:custom_php_inis].length > 0
      contents = ''
      @blueprint[:software][:custom_php_inis].each do |php_ini_hash|
        content = php_ini_hash[:content].gsub(/\r/, '')
        contents = contents + '\n' + content
      end
      write_software_file(SystemConfig.CustomPHPiniFile, contents)
    end
  end

  def create_apache_config
    p :apache_httpd_configurations
    p  @blueprint[:software][:apache_httpd_configurations]
    if @blueprint[:software].key?(:apache_httpd_configurations) \
    && @blueprint[:software][:apache_httpd_configurations].nil? == false \
    && @blueprint[:software][:apache_httpd_configurations].length > 0
      FileUtils.mkdir_p(get_basedir + File.dirname(SystemConfig.CustomApacheConfFile))
      #  @ if @blueprint[:software].key?(:apache_httpd_configurations) && @blueprint[:software][:apache_httpd_configurations]  != nil
      contents = ''
      @blueprint[:software][:apache_httpd_configurations].each do |httpd_configuration|
        contents = contents + httpd_configuration[:httpd_configuration] + '\n'
        p :apache
        p contents
      end
      write_software_file(SystemConfig.CustomApacheConfFile, contents)
    end
  end

  def write_software_file(container_filename_path, content)
    content.gsub!(/\r/, '')
    dir = File.dirname(get_basedir + container_filename_path)
    p :dir_for_write_software_file
    p dir
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    out_file  = File.open(get_basedir + container_filename_path, 'wb', :crlf_newline => false)
    content = @templater.process_templated_string(content)
    out_file.puts(content)
    out_file.close
  rescue StandardError => e
    log_exception(e)
  end

  def process_dockerfile_tmpl(filename)
    p :dockerfile_template_processing
    p filename
    template = File.read(filename)
    template = @templater.process_templated_string(template)
    output_filename = filename.sub(/.tmpl/, '')
    out_file = File.new(output_filename, 'wb')
    out_file.write(template)
    out_file.close
  end

  def compile_base_docker_files
    file_list = Dir.glob(@blueprint_reader.get_basedir + '/Dockerfile*.tmpl')
    file_list.each do |file|
      process_dockerfile_tmpl(file)
    end
  end

  def create_non_persistant_services
    @blueprint_reader.services.each do |service_hash|
      service_def = get_service_def(service_hash)
      return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
      next if service_def[:persistant]
      service_hash = set_top_level_service_params(service_hash)
      log_build_output('Attaching Non Persistant Service ' + service_hash[:service_label].to_s)
      return log_error_mesg('Failed to Attach ', service_hash) unless @core_api.attach_service(service_hash)
       @attached_services.push(service_hash)
    end
  end

  def get_service_def(service_hash)
    p service_hash[:type_path]
    p service_hash[:publisher_namespace]
    return SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
  end

  def set_top_level_service_params(service_hash)
    return ServiceManager.set_top_level_service_params(service_hash, @container_name)
  end

  def create_persistant_services
    service_cnt = 0
    @blueprint_reader.services.each do |service_hash|
      #   service_hash[:parent_engine]=@container_name # do I need this?
      service_def = get_service_def(service_hash)
      if service_def.nil?
        p :failed_to_load_service_definition
        p service_hash
        return false
      end
      if service_def[:persistant] == false
        service_cnt += 1
        next
      else
        service_hash[:persistant] = true
      end
      service_hash = set_top_level_service_params(service_hash)
      free_orphan = false
      p :adding_service
      # FIXME: need to unify filesystem creation with attach_service
      if service_hash[:servicetype_name] == 'filesystem'
        add_file_service(service_hash[:variables][:name], service_hash[:variables][:engine_path])
      end
      log_build_output('Attaching Persistant Service ' + service_hash[:service_handle].to_s)
      p :LOOKING_FOR_
      p service_hash
      if  @core_api.match_orphan_service(service_hash) == true
        p :attaching_orphan
        service_hash[:fresh] = false
        @first_build = false
        new_service_hash = reattach_service(service_hash)
        if new_service_hash.nil? == false
          service_hash = new_service_hash
          service_hash[:fresh] = false
          # @blueprint_reader.re_set_service(service_cnt,service_hash)#services[service_cnt]=service_hash
          free_orphan = true
          log_build_output('Reattached Service ' + service_hash[:service_handle].to_s)
        end
      elsif @core_api.service_is_registered?(service_hash) == false
        @first_build = true
        service_hash[:fresh] = true
        log_build_output('Creating New Service ' + service_hash[:service_handle].to_s)
      else # elseif over attach to existing true attached to existing
        service_hash[:fresh] = false
        log_build_output('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' No Service Found')
      end
      p :attach_service
      p service_hash
      @templater.fill_in_dynamic_vars(service_hash)
      fill_service_environment_variables(service_hash)
      p :with_env
      p service_hash
      # FIXME: release orphan should happen latter unless use reoprhan on rebuild failure
      if @core_api.attach_service(service_hash) == true
        @attached_services.push(service_hash)
        release_orphan(service_hash) if free_orphan == true
      end
      service_cnt += 1
    end
  end

  def reattach_service(service_hash)
    resuse_service_hash = @core_api.service_manager.reparent_orphan(service_hash)
    return resuse_service_hash
  end

  def release_orphan(service_hash)
    @core_api.service_manager.remove_orphaned_service(service_hash)
  end

  def tail_of_build_log
    retval = ''
    lines = File.readlines(SystemConfig.DeploymentDir + '/build.out')
    lines_count = lines.count - 1
    start = lines_count - 10
    for n in start..lines_count
      retval += lines[n]
    end
    return retval
  end

 

  def setup_rebuild
    log_build_output('Setting up rebuild')
    FileUtils.mkdir_p(get_basedir)
    blueprint = @core_api.load_blueprint(@engine)
    statefile = get_basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  rescue StandardError => e
    log_exception(e)
    close_all
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    mc = ManagedEngine.new(@container_name,
    @memory,
    @hostname,
    @domain_name,
    @container_name,
    @blueprint_reader.volumes,
    @web_port,
    @blueprint_reader.worker_ports,
    @repo_name,
    @blueprint_reader.databases,
    @blueprint_reader.environments,
    @blueprint_reader.framework,
    @blueprint_reader.runtime,
    @core_api.container_api,
    @blueprint_reader.data_uid,
    @blueprint_reader.data_gid,
    @blueprint_reader.deployment_type
    )
    # :http_protocol=>'HTTPS and HTTP'
    mc.set_protocol(@http_protocol)
    #mc.conf_self_start = true
    mc.save_state # no running.yaml throws a no such container so save so others can use
    log_build_errors('Failed to save blueprint ' + @blueprint.to_s) unless mc.save_blueprint(@blueprint)
    log_build_output('Launching')
    return log_build_errors('Error Failed to Launch') unless launch_deploy(mc)
    log_build_output('Applying Volume settings and Log Permissions')
    return log_build_errors('Error Failed to Apply FS') unless @core_api.run_volume_builder(mc, @web_user)
    return mc
  end

  def engine_environment
    return @blueprint_reader.environments
  end
  
 def log_error_mesg(m,o)
   log_build_errors(m.to_s + o.to_s)
   super
 end
 
  private

  def process_supplied_envs(custom_env)    
    p :custom_env
    p custom_env
    if custom_env.nil?
      @set_environments = {}
      @environments = []
    elsif custom_env.instance_of?(Array)
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      # FIXME: need to vet all environment variables
      @set_environments = {}
    else
      custom_env_hash = custom_env
      p :Merged_custom_env
      p custom_env_hash
      @set_environments = custom_env_hash
      @environments = []
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def create_build_dir
    FileUtils.mkdir_p(get_basedir)
  rescue StandardError => e
    log_exception(e)
  end

  def setup_log_output
    @log_file = File.new(SystemConfig.DeploymentDir + '/build.out', File::CREAT | File::TRUNC | File::RDWR, 0644)
    @err_file = File.new(SystemConfig.DeploymentDir + '/build.err', File::CREAT | File::TRUNC | File::RDWR, 0644)
    @log_pipe_rd, @log_pipe_wr = IO.pipe
    @error_pipe_rd, @error_pipe_wr = IO.pipe
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
    system_access = SystemAccess.new
    @templater = Templater.new(system_access, builder_public)
  rescue StandardError => e
    log_exception(e)
  end

  protected

  def fill_service_environment_variables(service_hash)
    p :fill_service_environment_variables
    service_envs = SoftwareServiceDefinition.service_environments(service_hash)
    @blueprint_reader.environments.concat(service_envs)
  end

  def debug(fld)
    puts 'ERROR: '
    p fld
  end

  def read_base_image_from_dockerfile
    p :read_base_image_from_dockerfile
    # FROM  engines/php:_Engines_System(release)
    dockerfile = File.open(get_basedir + '/Dockerfile', 'r')
    from_line = dockerfile.gets("\n", 100)
    p from_line
    from_part = from_line.gsub(/FROM[ ]./, '')
    return from_part
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
        p 'docker_cmd error ' + error_mesg
        @last_error = error_mesg
        return false
      end
      p :build_suceeded
      return true
    end
  end
  def get_basedir
    return SystemConfig.DeploymentDir + '/' + @build_name
  end

  def log_exception(e)
    log_build_errors(e.to_s)
    super
  end
end
