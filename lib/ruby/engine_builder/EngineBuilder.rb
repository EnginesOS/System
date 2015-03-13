require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require "/opt/engines/lib/ruby/containers/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/containers/ManagedEngine.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require "/opt/engines/lib/ruby/system/SysConfig.rb"
require "rubygems"
require "git"
require 'fileutils'
require 'json'

require_relative 'BluePrintReader.rb'
require_relative 'DockerFileBuilder.rb'
require_relative 'SystemAccess.rb'
require_relative 'templating.rb'
include Templating

class EngineBuilder
  @repoName=nil
  @hostname=nil
  @domain_name=nil
  @build_name=nil
  @web_protocol="HTTPS and HTTP"

  
  attr_reader :last_error,
              :repoName,
              :hostname,
              :domain_name,
              :build_name,
              :set_environments,
              :container_name,
              :environments,
              :runtime,
              :webPort,
              :http_protocol,
              :blueprint,
              :first_build
              
  class BuildError < StandardError
    attr_reader :parent_exception,:method_name
    def initialize(parent,method_name)
      @parent_exception = parent
    end

  end

  #This class is to isolate the builder from the docker template output
  
  class BuilderPublic
    def initialize(builder)
     @builder = builder
    end
     def engine_name
       @builder.container_name
     end
     def domain_name
       @builder.domain_name
     end
     def hostname 
       @builder.hostname
     end
     def http_protocol
       @builder.http_protocol
     end
     def repoName
       @builder.repoName
     end
     def webPort
       @builder.webPort
     end
     def build_name
       @builder.build_name
     end
     def runtime
       @builder.runtime
     end     
     def fqdn
       return @builder.hostname + "." + @builder.domain_name
     end
     def set_environments 
       @builder.set_environments
     end     
     def environments
       @builder.environments
     end
     
     def mysql_host
       return "mysql.engines.internal"
     end
     
     def blueprint
       return @builder.blueprint
     end
     
     def random cnt
       len = cnt.to_i
       rnd = SecureRandom.hex(len)
#       p :RANDOM__________
#       p rnd.byteslice(0,len) 
       return rnd.byteslice(0,len) 
     end
     
     
    
  end

  def initialize(params,core_api)
    @container_name = params[:engine_name]
    @domain_name = params[:domain_name]
    @hostname = params[:host_name]
    custom_env= params[:software_environment_variables]
    #   custom_env=params
    @core_api = core_api
    @http_protocol = params[:http_protocol]
    p params
    @repoName= params[:repository_url]
    @cron_job_list = Array.new
    @build_name = File.basename(@repoName).sub(/\.git$/,"")
    @workerPorts=Array.new
    @webPort=8000
    @vols=Array.new
    @first_build = true
    #FIXme will be false but for now
    @overwrite_existing_services = true 
    
    @builder_public = BuilderPublic.new(self)
    @system_access = SystemAccess.new()
    p :custom_env
    p custom_env

    if custom_env == nil
      @set_environments = Hash.new
      @environments = Array.new
    elsif  custom_env.instance_of?(Array) == true
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      #FIXME need to vet all environment variables
      @set_environments = Hash.new
    else
      env_array = custom_env.values
      custom_env_hash = Hash.new

      env_array.each do |env_hash|
        p :env_hash
        p env_hash

        if env_hash != nil && env_hash[:name] !=nil && env_hash[:value] != nil
          env_hash[:name] = env_hash[:name].sub(/_/,"")
          custom_env_hash.store(env_hash[:name],env_hash[:value])
        end
      end
      p :Merged_custom_env
      p custom_env_hash
      @set_environments =  custom_env_hash
      @environments = Array.new
    end
    @runtime=String.new
    @databases= Array.new

    begin
      FileUtils.mkdir_p(get_basedir)
      @log_file=  File.new(SysConfig.DeploymentDir + "/build.out", File::CREAT|File::TRUNC|File::RDWR, 0644)
      @err_file=  File.new(SysConfig.DeploymentDir + "/build.err", File::CREAT|File::TRUNC|File::RDWR, 0644)
      @log_pipe_rd, @log_pipe_wr = IO.pipe
      @error_pipe_rd, @error_pipe_wr = IO.pipe
    rescue
      SystemUtils.log_exception(e)
    end
  end

  def close_all
    if @log_file.closed? == false
      @log_file.close()
    end
    if@err_file.closed? == false
      @err_file.close()
    end

    if @log_pipe_wr.closed? == false
      @log_pipe_wr.close()
    end

    if @error_pipe_wr.closed? == false
      @error_pipe_wr.close()
    end
  end

  def get_build_log_stream
    return @log_pipe_rd
  end

  def get_build_err_stream
    @error_pipe_rd
  end

  def  log_build_output(line)
    @log_file.puts(line)
    @log_file.flush
    # @log_pipe_wr.puts(line)
  rescue
    return

  end

  def log_build_errors(line)
    @err_file.puts(line)
    @err_file.flush
    #    @error_pipe_wr.puts(line)
  end

  def setup_framework_logging
    begin
      rmt_log_dir_var_fname=get_basedir + "/home/LOG_DIR"
      if File.exist?(rmt_log_dir_var_fname)
        rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
        rmt_log_dir = rmt_log_dir_varfile.read
      else
        rmt_log_dir="/var/log"
      end
      local_log_dir = SysConfig.SystemLogRoot + "/containers/" + @hostname
      if Dir.exist?(local_log_dir) == false
        Dir.mkdir( local_log_dir)
      end

      return " -v " + local_log_dir + ":" + rmt_log_dir + ":rw "

    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def backup_lastbuild
    begin
      dir=get_basedir

      if Dir.exist?(dir)
        backup=dir + ".backup"
        if Dir.exist?(backup)
          FileUtils.rm_rf backup
        end
        FileUtils.mv(dir,backup)
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
      #throw BuildException.new(e,"backup_lastbuild")
    end
  end

  def load_blueprint
    begin
      log_build_output("Reading Blueprint")
      blueprint_file_name= get_basedir + "/blueprint.json"
      blueprint_file = File.open(blueprint_file_name,"r")
      blueprint_json_str = blueprint_file.read
      blueprint_file.close

      # @blueprint = JSON.parse(blueprint_json_str)
      json_hash = JSON.parse(blueprint_json_str)
      p :symbolized_hash
#      test_hash = json_hash
#      test_hash.keys.each do |key|
#        test_hash[(key.to_sym rescue key) || key] = myhash.delete(key)
#      end
#      p test_hash
  hash =  SystemUtils.symbolize_keys(json_hash)
      return hash
      
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def clone_repo
    begin
      log_build_output("Clone Blueprint Repository")
      g = Git.clone(@repoName, @build_name, :path => SysConfig.DeploymentDir)
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end



#  def create_cron_service
#    begin
#
#      log_build_output("Cron file")
#
#      if @blueprint_reader.cron_jobs != nil && @blueprint_reader.cron_jobs.length >0
#
#        @blueprint_reader.cron_jobs.each do |cj|
#          cj_hash = Hash.new
#          cj_hash[:name] =@container_name
#          cj_hash[:container_name] = @container_name
#          cj_hash[:cron_job]=cj
#          cj_hash[:parent_engine] = @containerName
#          #               cron_file.puts(cj)
#          #               p :write_cron_job
#          #               p cj
#          @cron_job_list.push(cj_hash)
#          p @cron_job_list
#        end
#        #             cron_file.close
#      end
#
#      return true
#
#    rescue Exception=>e
#      log_exception(e)
#      return false
#    end
#  end

  def setup_default_files
    log_build_output("Setup Default Files")
    if setup_global_defaults == false
      return false
    else
      return setup_framework_defaults
    end
  end
#
#  def create_db_service(name,flavor)
#    begin
#      log_build_output("Create DB Service")
#      db = DatabaseService.new(@hostname,name,SysConfig.DBHost,name,name,flavor)
#      databases.push(db)
#      create_database_service db
#    rescue Exception=>e
#      log_exception(e)
#      return false
#    end
#  end

  def build_init
    begin
      log_build_output("Building Image")
      # cmd="cd " + get_basedir + "; docker build  -t " + @hostname + "/init ."
      cmd="/usr/bin/docker build  -t " + @container_name + "/deploy " +  get_basedir
      puts cmd
      res = run_system(cmd)
      if res != true
        puts "build init failed " + res.to_s
        return res
      end
      return res
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def launch_deploy managed_container
    begin
      log_build_output("Lauching Engine")
      retval =  managed_container.create_container
      if retval == false
        puts "Failed to Start Container " +  managed_container.last_error
        log_build_errors("Failed to Launch")
      end

      return retval
    rescue Exception=>e

      SystemUtils.log_exception(e)
      return false
    end
  end

  def setup_global_defaults
    begin
      log_build_output("Setup globel defaults")
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def setup_framework_defaults
    log_build_output("Copy in default templates")
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" +  @blueprint_reader.framework + "/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def get_blueprint_from_repo
    log_build_output("Backup last build")
    if backup_lastbuild == false
      return false
    end
    puts("Cloning Blueprint")
    return clone_repo
  end

  def build_from_blue_print
    if get_blueprint_from_repo == false
      return false
    end
    return build_container
  end

  def read_web_port
    log_build_output("Setting Web port")
    begin
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("PORT")
          i= line.split('=')
          @webPort= i[1].strip
          p :web_port_line
          p line
        end
        p @webPort
        puts(@webPort)
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
      #      throw BuildException.new(e,"setting web port")
      return false
    end
  end

  def read_web_user
    begin
      log_build_output("Read Web User")
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("USER")
          i= line.split('=')
          @webUser= i[1].strip
        end
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def build_container
    begin

      log_build_output("Reading Blueprint")
      @blueprint = load_blueprint
      if @blueprint ==  nil ||  @blueprint == false
        return false
      end

      @blueprint_reader = BluePrintReader.new(@build_name,@container_name,@blueprint,self)
      @blueprint_reader.process_blueprint

      if  setup_default_files == false
        return false
      end
      
      
      
      compile_base_docker_files

      if @blueprint_reader.web_port != nil
        @webPort = @blueprint_reader.web_port
      else
        read_web_port
      end
      
      read_web_user
      
      create_persistant_services #need to de-register these if build fails But not deregister those that existed prior
      
    
        @blueprint_reader.environments.each do |env|
          p :env_before
          p env.value
              env.value = process_templated_string(env.value)
              p :env_after
              p env.value
          end
          fill_service_environment_varibles
          create_template_files
          create_php_ini
          create_apache_config                 
          create_scritps
          
                 index=0
                 #FIXME There has to be a ruby way
                 @blueprint_reader.sed_strings[:sed_str].each do |sed_string|                   
                   sed_string = process_templated_string(sed_string)
                   @blueprint_reader.sed_strings[:sed_str][index] = sed_string
                   index+=1
                  end       
    
      dockerfile_builder = DockerFileBuilder.new( @blueprint_reader,@container_name, @hostname,@domain_name,@webPort,self)
      dockerfile_builder.write_files_for_docker
      
      env_file = File.new(get_basedir + "/home/app.env","a")
      env_file.puts("")
      @blueprint_reader.environments.each do |env|
        env_file.puts(env.name)
      end
      @set_environments.each do |env|
        env_file.puts(env[0])
      end
      env_file.close

      setup_framework_logging

#      log_build_output("Creating db Services")
#      @blueprint_reader.databases.each() do |db|
#        create_database_service db
#      end
      
     
      if  build_init == false
        log_build_errors("Error Build Image failed")
        @last_error =  " " + tail_of_build_log
        post_failed_build_clean_up
        return false
      else

        if @core_api.image_exists?(@container_name) == false
          @last_error = " " + tail_of_build_log
          post_failed_build_clean_up
          return false
          #return EnginesOSapiResult.failed(@container_name,"Build Image failed","build Image")
        end

        #needs to be moved to services dependant on the new BPDS
        #create_cron_service

#        log_build_output("Creating vol Services")
#        @blueprint_reader.databases.each() do |db|
#          create_database_service db
#        end
#
#        primary_vol=nil
#        @blueprint_reader.volumes.each_value() do |vol|
#          create_file_service vol
#          if primary_vol == nil
#            primary_vol =vol
#          end
#        end
        log_build_output("Creating Deploy Image")
        mc = create_managed_container()
        if mc != nil
          create_non_persistant_services   
        end
      end

      close_all

      return mc

    rescue Exception=>e

  SystemUtils.log_exception(e)
    post_failed_build_clean_up
      close_all
      return false
    end
  end

  def post_failed_build_clean_up
    #remove containers
    #remove persistant services (if created/new)
    #deregister non persistant services (if created)
    p :Clean_up_Failed_build
    @blueprint_reader.services.each do |service_hash|
      if service_hash[:fresh] == true 
        service_hash[:delete_persistant]=true
        @core_api.dettach_service(service_hash) #true is delete persistant
      end
    end
  end
  
  def create_template_files
    if  @blueprint[:software].has_key?(:template_files) && @blueprint[:software][:template_files] != nil
      @blueprint[:software][:template_files].each do |template_hash|
        write_software_file( "/home/engines/templates/" + template_hash[:path],template_hash[:content])
    end
  end
  end
  
  def create_httaccess
    if @blueprint[:software].has_key?(:apache_htaccess_files) && @blueprint[:software][:apache_htaccess_files]  != nil
      @blueprint[:software][:apache_htaccess_files].each do |htaccess_hash|
        write_software_file("/home/engines/htaccess_files" + template_hash[:directory]+"/.htaccess",template_hash[:htaccess_content])
      end
    end
  end
  
  def   create_scritps
    
      FileUtils.mkdir_p(get_basedir() + SysConfig.ScriptsDir)      
      create_start_script
      create_install_script
      create_post_install_script
  end
  
   def create_start_script
     if @blueprint[:software].has_key?(:custom_start_script) &&  @blueprint[:software][:custom_start_script] != nil
       start_script_file = File.open(get_basedir() + SysConfig.StartScript,"w", :crlf_newline => false)
       start_script_file.puts(@blueprint[:software][:custom_start_script])
       start_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.StartScript)
     end
   end
   
   def create_install_script
     if @blueprint[:software].has_key?(:custom_install_script) &&  @blueprint[:software][:custom_install_script] != nil
       install_script_file = File.open(get_basedir() + SysConfig.InstallScript,"w", :crlf_newline => false)
       install_script_file.puts(@blueprint[:software][:custom_install_script])
       install_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.InstallScript)
       end     
   end
   def create_post_install_script
     if @blueprint[:software].has_key?(:custom_post_install_script) && @blueprint[:software][:custom_post_install_script] != nil
       post_install_script_file = File.open(get_basedir() + SysConfig.PostInstallScript,"w", :crlf_newline => false)
       post_install_script_file.puts(@blueprint[:software][:custom_post_install_script])
       post_install_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.PostInstallScript)
       end    
   end
  def create_php_ini
    FileUtils.mkdir_p(get_basedir() + File.dirname(SysConfig.CustomPHPiniFile))
    if @blueprint[:software].has_key?(:custom_php_inis) && @blueprint[:software][:custom_php_inis]  != nil
      
      php_ini_file = File.open(get_basedir() + SysConfig.CustomPHPiniFile,"w", :crlf_newline => false)              
      @blueprint[:software][:custom_php_inis].each do |php_ini_hash|
        php_ini_file.puts(php_ini_hash[:content])
      end
      php_ini_file.close
       
    end
  end
    
    def create_apache_config
      FileUtils.mkdir_p(get_basedir() + File.dirname(SysConfig.CustomApacheConfFile))
      if @blueprint[:software].has_key?(:custom_apache_conf) && @blueprint[:software][:custom_apache_conf]  != nil            
        write_software_file(SysConfig.CustomApacheConfFile,@blueprint[:software][:custom_apache_conf])               
         
      end  
  end
 
  def write_software_file(container_filename_path,content)
    dir = File.dirname(get_basedir() + container_filename_path)
    p :dir_for_write_software_file
    p dir
    
    if Dir.exist?(dir) == false
      FileUtils.mkdir_p(dir)
    end
   out_file  = File.open(get_basedir() + container_filename_path ,"w", :crlf_newline => false)
   content = process_templated_string(content)
   out_file.puts(content)
   
   out_file.close
   
  rescue Exception=>e
    if out_file
      if contents != nil
        out_file.puts(content)
      end      
      out_file.close
    end
    SystemUtils.log_exception(e)
 end
 
def process_dockerfile_tmpl(filename)
  p :dockerfile_template_processing
  p filename
  template = File.read(filename)
  
  template = process_templated_string(template)
  output_filename = filename.sub(/.tmpl/,"")
  
  out_file = File.new(output_filename,"w")
  out_file.write(template)
  out_file.close()            
end

  def  compile_base_docker_files
    
    file_list = Dir.glob(@blueprint_reader.get_basedir + "/Dockerfile*.tmpl")
      file_list.each do |file|
        process_dockerfile_tmpl(file)
      end 
              
  end
  
 
  
  def create_non_persistant_services
    @blueprint_reader.services.each() do |service_hash|
       #FIX ME Should call this but Keys dont match blueprint designer issue
       #@core_api.add_service(service,mc)     
      service_hash[:parent_engine]=@container_name
    if service_hash.has_key?(:variables) == false
      service_hash[:variables] = Hash.new
    end
      service_hash[:variables][:parent_engine]=@container_name
       service_def =  get_service_def(service_hash)
      if service_def == nil
        p :failed_to_load_service_definition
        p service_hash[:type_path]
        p service_hash[:publisher_namespace]
        return false
      end
        if service_def[:persistant] == true
          next                 
        end
      service_hash[:service_handle] = service_hash[:variables][:name]
         p :adding_service
         p service_hash   
      @core_api.attach_service(service_hash)
       end
  end
  
  
  def get_service_def(service_hash)
    p service_hash[:type_path]
      p service_hash[:publisher_namespace]
    return     SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace] )
  end
  
  def create_persistant_services
    @blueprint_reader.services.each() do |service_hash|
      
      service_hash[:parent_engine]=@container_name
      if service_hash.has_key?(:variables) == false
          service_hash[:variables] = Hash.new
        end
      service_hash[:variables][:parent_engine]=@container_name
#      p :service_def_for
#      p service_hash[:type_path]
#      p service_hash[:publisher_namespace]
   
      service_def = get_service_def(service_hash)
#      p  service_def
       
       if service_def == nil
         p :failed_to_load_service_definition
         p :servicetype_name
         p service_hash[:service_type]
         p :service_provider
         p service_hash[:publisher_namespace]
         return false
       end
      if service_def[:persistant] == false
        next                 
      end
      service_hash[:persistant] =true
      p :adding_service
     
      puts "+=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++"
      p service_hash   
      puts "+=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++"
      p :target_envs
      p service_def[:target_environment_variables]
     
      if service_hash[:servicetype_name] == "filesystem"
         add_file_service(service_hash[:variables][:name], service_hash[:variables][:engine_path])
      end

      service_hash[:service_handle] = service_hash[:variables][:name]
        p :LOOKING_FOR_
        p service_hash
     if  @core_api.find_service_consumers(service_hash) == false              
       @first_build = true
       service_hash[:fresh]=true
     else       
       service_hash[:fresh]=false
       @first_build = false
     end
      p :attach_service
       p service_hash
      @core_api.attach_service(service_hash)
            
    end
  end
  
  def fill_in_dynamic_vars(service_hash)
    p "FILLING_+@+#+@+@+@+@+@+"
    if service_hash.has_key?(:variables) == false || service_hash[:variables] == nil
      return
    end
    service_hash[:variables].each do |variable|
      p variable
      if variable[1] != nil && variable[1].start_with?("_")
      #variable[1].sub!(/\$/,"")
        result = evaluate_function(variable[1])
        service_hash[:variables][variable[0]] = result
    end
  end
end
def evaluate_function(function)
     if function.start_with?("_System")
       return resolve_system_variable(function)
     elsif function.start_with?("_Builder")
       return resolve_build_variable(function)
     elsif function.start_with?("_Blueprint")
       return resolve_blueprint_variable(function)
     end
     #if no match return orginial
     return function
rescue Exception=> e
  return ""
  
end
  def tail_of_build_log
    retval = String.new
    lines = File.readlines(SysConfig.DeploymentDir + "/build.out")
    lines_count = lines.count -1
    start = lines_count - 10
    for n in start..lines_count
      retval+=lines[n]
    end
    return retval
  end

  def rebuild_managed_container  engine
    @engine  = engine
    log_build_output("Starting Rebuild")
    if backup_lastbuild == false
      return false
    elsif setup_rebuild == false
      return false
    else
      return build_container
    end
  end

  def setup_rebuild
    begin
      log_build_output("Setting up rebuild")
      FileUtils.mkdir_p(get_basedir)
      blueprint = @core_api.load_blueprint(@engine)
      statefile= get_basedir + "/blueprint.json"
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.write(blueprint.to_json)
      f.close
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def create_managed_container
    log_build_output("Creating ManagedEngine")
    mc = ManagedEngine.new(@hostname,
    @blueprint_reader.memory.to_s ,
    @hostname,
    @domain_name,
    @container_name + "/deploy",
    @blueprint_reader.volumes,
    @webPort,
    @blueprint_reader.workerPorts,
    @repoName,
    @blueprint_reader.databases,
    @blueprint_reader.environments,
    @blueprint_reader.framework,
    @blueprint_reader.runtime,
    @core_api,
    @blueprint_reader.data_uid,
    @blueprint_reader.data_gid
    )

    p :set_cron_job_list
    p @cron_job_list
    mc.set_cron_job_list(@cron_job_list)
    #:http_protocol=>"HTTPS and HTTP"
    mc.set_protocol(@protocol)
    mc.conf_register_site=( true) # needs some intelligence here for worker only
    mc.conf_self_start= (true)
    mc.save_state # no config.yaml throws a no such container so save so others can use
    if mc.save_blueprint(@blueprint) == false
      log_build_errors( "Failed to save blueprint " + @blueprint.to_s)
    end

    bp = mc.load_blueprint
    p  bp
    log_build_output("Launching")
    #this will fail as no api at this stage
    if mc.core_api != nil
      if launch_deploy(mc) == false
        log_build_errors("Failed to Launch")
      end
      log_build_output("Applying Volume settings and Log Permissions")
      #FIXME need to check results from following
      @core_api.run_volume_builder(mc ,@webUser)
      #  mc.start_container
    end
    return mc
  end

  protected

def fill_service_environment_varibles
  
  services = @blueprint_reader.services
    services.each do |service_hash|
      service_def =  get_service_def(service_hash)
               if service_def != nil
                 service_environment_variables = service_def[:target_environment_variables]
                 if service_environment_variables != nil
                      service_environment_variables.values.each do |env_variable_pair|
                        env_name = env_variable_pair[:environment_name]
                        value_name = env_variable_pair[:variable_name]
                        value=service_hash[:variables][value_name.to_sym] 
                   @blueprint_reader.environments.push( EnvironmentVariable.new(env_name,value,false,true,true,service_hash[:type_path] + env_name,true)) # env_name , value
                      end
                 end   
               end
    end
end

  def debug(fld)
    puts "ERROR: "
    p fld
  end

  require 'open3'

  def run_system(cmd)
    log_build_output("Running " + cmd)
    ret_val=false
    res = String.new
    error_mesg = String.new
    begin
      Open3.popen3( cmd ) do |stdin, stdout, stderr, th|
        oline = String.new
        stderr_is_open=true

        begin
          stdout.each { |line|
            #  print line
            line = line.gsub(/\\\"/,"")
            res += line.chop
            oline = line
            log_build_output(line)
            if stderr_is_open
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              log_build_errors(err)
            end
          }
        rescue Errno::EIO
          res += line.chop
          log_build_output(oline)
          if stderr_is_open
            err  = stderr.read_nonblock(1000)
            error_mesg += err
            log_build_errors(err)
            p :EIO_retry
            retry
          end
        rescue  IO::WaitReadable
          # p :wait_readable_retrt
          retry
        rescue EOFError
          if stdout.closed? == false
            stderr_is_open = false
            p :EOF_retry
            retry
          elsif  stderr.closed? == true
              return
            else
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              log_build_errors(err)           
            end
          end
        end
   
      
      log_build_errors(error_mesg)
        if error_mesg.include?("Error:") || error_mesg.include?("FATA")
          p "docker_cmd error " + error_mesg
          return false
        end
        p :build_suceed
        return true
      end

  end

  def get_basedir
    return SysConfig.DeploymentDir + "/" + @build_name
  end
end

