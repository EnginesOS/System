class EnginesCore

  require "/opt/engines/lib/ruby/SystemUtils.rb"
  require "/opt/engines/lib/ruby/system/DNSHosting.rb"
  require_relative 'DockerApi.rb'
  require_relative 'SystemApi.rb'
  

 
 

  def initialize
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  #will change to to docker_api and not self
    @last_error = String.new
  end

  attr_reader :last_error

  def software_service_definition(params)
    sm = loadServiceManager
    return sm.software_service_definition(params)
  end

  def add_domain(params)
    return  @system_api.add_domain(params)
  end

#
#  def remove_containers_cron_list(containerName)
#    p :remove_containers_cron
#    if @system_api.remove_containers_cron_list(containerName)
#      cron_service = loadManagedService("cron")
#      return @system_api.rebuild_crontab(cron_service)
#    else
#      return false
#    end
#  end
#
#  def rebuild_crontab(cron_service)
#    #acutally a rebuild (or resave) as hadh already removed from consumer list
#    p :rebuild_crontab
#    return  @system_api.rebuild_crontab(cron_service)
#  end

  def remove_domain(params)
    return @system_api.rm_domain(params[:domain_name],@system_api)
  end

  def update_domain(old_domain,params)
    return @system_api.update_domain(old_domain,params,@system_api)
  end

  def signal_service_process(pid,sig,name)
    container = loadManagedService(name)
    return @docker_api.signal_container_process(pid,sig,container)
  end

  def start_container(container)
    if @docker_api.start_container(container) == true
      return true
    end
    return false
  end

  def inspect_container(container)
    return  @docker_api.inspect_container(container)
  end

  def stop_container(container)
    if @docker_api.stop_container(container) == true
      return  true
    end
    return false
  end

  def pause_container(container)
    return  @docker_api.pause_container(container)
  end

  def  unpause_container(container)
    return  @docker_api.unpause_container(container)
  end

  def  ps_container(container)
    return  @docker_api.ps_container(container)
  end

  def  logs_container(container)
    return  @docker_api.logs_container(container)
  end

  
  def add_monitor(site_hash)
    return @system_api.add_monitor(site_hash)
  end

  def rm_monitor(site_hash)
    return @system_api.rm_monitor(site_hash)
  end

  def save_container(container)
    return @system_api.save_container(container)
  end

  def save_blueprint(blueprint,container)
    return @system_api.save_blueprint(blueprint,container)
  end

  def load_blueprint(container)
    return @system_api.load_blueprint(container)
  end

  def add_volume(site_hash)
    return @system_api.add_volume(site_hash)
  end

  def rm_volume(site_hash)
    return @system_api.rm_volume(site_hash)
  end



  def remove_self_hosted_domain(domain_name)
    return @system_api.remove_self_hosted_domain(domain_name)
  end

  def add_self_hosted_domain(params)
    return @system_api.add_self_hosted_domain(params)
  end

  def list_self_hosted_domains()
    return @system_api.list_self_hosted_domains()
  end

  def  update_self_hosted_domain(old_domain_name, params)
    @system_api.update_self_hosted_domain(old_domain_name, params)
  end

  def load_system_preferences
    return @system_api.load_system_preferences
  end

  def save_system_preferences
    return @system_api.save_system_preferences
  end

  def register_site(site_hash)
    return @system_api.register_site(site_hash)
  end

  def deregister_site(site_hash)
    return @system_api.deregister_site(site_hash)
  end

  def hash_to_site_str(site_hash)
    return @system_api.hash_to_site_str(site_hash)
  end

  def  deregister_dns(top_level_hostname)
    return @system_api.deregister_dns(top_level_hostname)
  end

  def register_dns(top_level_hostname,ip_addr_str)
    return @system_api.register_dns(top_level_hostname,ip_addr_str)
  end

  def get_container_memory_stats(container)
    return @system_api.get_container_memory_stats(container)
  end

  def set_engine_hostname_details(container,params)
    return @system_api.set_engine_hostname_details(container,params)
  end

  def image_exists?(containerName)
    imageName = containerName +"/deploy"
    return @docker_api.image_exists?(imageName)
    rescue Exception=>e
    log_execption(e)
    return false
  end

  def list_attached_services_for(objectName,identifier)
    sm = loadServiceManager()
    return sm.list_attached_services_for(objectName,identifier)
    rescue Exception=>e
               log_exception e

    #    object_name = object.class.name.split('::').last
    #
    #    case object_name
    #    when  "ManagedEngine"
    #      retval = Hash.new
    #
    #    retval[:database] = object.databases
    #    retval[:volume] = object.volumes
    #    retval[:cron] = object.cron_job_list
    #
    #      return retval
    #
    #      #list services
    #      # which includes volumes databases cron
    #    end
    #    p "missed object name"
    #    p object_name
    #
    #    service_manager = loadServiceManager()
    #
    #    if service_manager !=nil
    #      return service_manager.attached_services(object)
    #
    #    end
    #    return false

  end

  def list_avail_services_for(object)
    objectname = object.class.name.split('::').last
    services = load_avail_services_for(objectname)
    subservices = load_avail_component_services_for(object)

    retval = Hash.new
    retval[:services] = services
    retval[:subservices] = subservices
    return retval
    rescue Exception=>e
               log_exception e
  end

  def load_software_service(params)

    sm = loadServiceManager()
    p :load_software_service
    p params
    service_container =  sm.get_software_service_container_name(params)
    params[:service_container_name] = service_container
    p :service_container_name
    p service_container
    service = loadManagedService(service_container)
    if service == nil
      return nil
    end

    return service
    rescue Exception=>e
               log_exception e
  end

  def setup_email_params(params)
      
       arg="smarthost_hostname=" + params[:smarthost_hostname] \
         + ":smarthost_username=" + params[:smarthost_username]\
         + ":smarthost_password=" + params[:smarthost_password]\
         + ":mail_name=smtp."  + params[:default_domain] 
     container=loadManagedService("smtp")
    return @docker_api.docker_exec(container,SysConfig.SetupParamsScript,arg)
    rescue   Exception=>e
      log_exception(e)
  end
  
   def set_database_password(container_name,params)
     arg = "mysql_password=" + params[:mysql_password] +":" \
          + "server=" + container_name + ":" \
        +  "psql_password=" + params[:psql_password] #Need two args
          if container_name 
              server_container = loadManagedService(container_name)
              return @docker_api.docker_exec(server_container,SysConfig.SetupParamsScript,arg)
          end
          
          return true
          
   rescue Exception=>e
       log_exception(e)
       return false
   end
  
  def attach_service(service_hash)
 
    if service_hash == nil
      p :attached_Service_passed_nil
      return false
    end
    
    service = load_software_service(service_hash)
    p :attaching_to_service
    p service_hash
    if service !=nil && service != false
      return service.add_consumer(service_hash)
    end
    @last_error = "Failed to attach Service: " + @last_error 
    return  false
    rescue Exception=>e
                  log_exception e
  end

  def dettach_service(params)
    service = load_software_service(params)
    if service !=nil && service != false
          return service.remove_consumer(params)
        end
        @last_error = "Failed to dettach Service: " + @last_error 
        return  false
        rescue Exception=>e
                      log_exception e
 
  end

  def list_providers_in_use
    sm = loadServiceManager()
       return sm.list_providers_in_use
  end
  
  def loadServiceManager()
    if @service_manager == nil
      @service_manager = ServiceManager.new()
      return @service_manager
    end
    return @service_manager
  end

  def find_service_consumers(params)
    sm = loadServiceManager()
    return sm.find_service_consumers(params)
  end

  def find_engine_services(params)
    sm = loadServiceManager()
        return sm.find_engine_services(params)
      end

  def load_service_definition(filename)

    yaml_file = File.open(filename)
    p :open
    p filename
    return  SoftwareServiceDefinition.from_yaml(yaml_file)
  rescue
    rescue Exception=>e
               log_exception e
  end

  def load_avail_services_for(objectname)
    p :load_avail_services_for
    p objectname
    retval = Array.new

    dir = SysConfig.ServiceMapTemplateDir + "/" + objectname
    p :dir
    p dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
           if service_dir_entry.start_with?(".")   == true
             next
           end
          p :service_dir_entry
          p service_dir_entry
          if service_dir_entry.end_with?(".yaml")
            service = load_service_definition(dir + "/" + service_dir_entry)
            if service != nil
              p :service_as_serivce
              p service
              p :as_hash
              p service.to_h
              p :as_yaml
              p service.to_yaml()
              
              retval.push(service.to_h)
            end
          end
        rescue Exception=>e
          log_exception e
          next
        end
      end
    end
    p objectname
    p retval
    return retval
    rescue Exception=>e
             log_exception e
  end

  def load_avail_component_services_for(object)
    retval = Hash.new
    if object.is_a?(ManagedEngine)
      if object.volumes.count >0
        p :loading_vols
        volumes = load_avail_services_for("Volume") #Array of hashes
        retval[:volume] = volumes
      end
      if object.databases.count >0
        databases = load_avail_services_for("Database") #Array of hashes
        retval[:database] = databases
      end

      return retval
    else
      return nil
 
    end
         rescue Exception=>e
           log_exception e
  end

  def set_engine_runtime_properties(params)
    #FIX ME also need to deal with Env Variables
    engine_name = params[:engine_name]

    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult) == true
      last_error = engine.result_mesg
      return false
    end

    if engine.is_active == true
      last_error="Container is active"
      return false
    end

    if params.has_key?(:memory)
      if params[:memory] == engine.memory
        last_error="No Change in Memory Value"
        return false
      end

      if engine.update_memory(params[:memory]) == false
        last_error= engine.last_error
        return false
      end
    end

    if engine.has_container? == true
      if destroy_container(engine)  == false
        last_error= engine.last_error
        return false
      end
    end

    if  create_container(engine) == false
      last_error= engine.last_error
      return false
    end
    return true

  end

  def set_engine_network_properties (engine, params)
    return @system_api.set_engine_network_properties(engine,params)
  end

  def get_system_load_info
    return @system_api.get_system_load_info
  end

  def get_system_memory_info
    return @system_api.get_system_memory_info
  end

  def getManagedEngines
    return @system_api.getManagedEngines
  end

  def loadManagedEngine(engine_name)
    return @system_api.loadManagedEngine(engine_name)
  end

  def loadManagedService(service_name)
    return @system_api.loadManagedService(service_name)
  end

  def getManagedServices
    return @system_api.getManagedServices
  end

  def list_domains
    return @system_api.list_domains
  end

  def list_managed_engines
    return @system_api.list_managed_engines
  end

  def list_managed_services
    return @system_api.list_managed_services
  end

  def destroy_container(container)
    clear_error
    begin
      if @docker_api.destroy_container(container) != false
        container.deregister_registered
        @system_api.destroy_container(container)  #removes cid file
        return true
      else
        return false
      end
    rescue Exception=>e
      container.last_error=( "Failed To Destroy " + e.to_s)
      log_exception(e)

      return false
    end
  end


  def delete_image(container)
    begin
      clear_error

      if @docker_api.delete_image(container) == true
        res = @system_api.delete_container_configs(container)
        return res
      else
        return false
      end

    rescue Exception=>e
      container.last_error=( "Failed To Delete " + e.to_s)
      log_exception(e)
      return false

    end
  end

  def run_system(cmd)
    clear_error
    begin
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>
      SystemUtils.debug_output res
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
        return true
      else
        @last_error = res
        SystemUtils.debug_output res
        return false
      end
    rescue Exception=>e
      log_exception(e)
      return ret_val
    end
  end

  def run_volume_builder(container,username)
    clear_error
    begin
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        command = "docker stop volbuilder"
        run_system(command)
        command = "docker rm volbuilder"
        run_system(command)
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      mapped_vols = get_volbuild_volmaps container
      command = "docker run --name volbuilder --memory=20m -e fw_user=" + username + " --cidfile /opt/engines/run/volbuilder.cid " + mapped_vols + " -t engines/volbuilder /bin/sh /home/setup_vols.sh "
      SystemUtils.debug_output command
      run_system(command)
      command = "docker stop volbuilder;  docker rm volbuilder"
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      res = run_system(command)
      if  res != true
        log_error(res)
        return false
      end
      return true
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_container(container)
    clear_error
    begin
      if @system_api.clear_cid(container) != false
        @system_api.clear_container_var_run(container)
        if  @docker_api.create_container(container) == true
          return @system_api.create_container(container)
        end
      else
        return false
      end
    rescue Exception=>e
      container.last_error=("Failed To Create " + e.to_s)
      log_exception(e)

      return false
    end
  end

  def rebuild_image(container)
    clear_error
    begin
      params=Hash.new
      params[:engine_name] = container.containerName
      params[:domain_name] = container.domainName
      params[:host_name] = container.hostName
      params[:env_variables] = container.environments
      params[:http_protocol] = container.protocol
      params[:repository_url]  = container.repo
      params[:software_environment_variables] = container.environments
   #   custom_env=params    
   #  @http_protocol = params[:http_protocol] = container.
      builder = EngineBuilder.new(params, self)
      return  builder.rebuild_managed_container(container)
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end
#  @container_name = params[:engine_name]
#    @domain_name = params[:domain_name]
#    @hostname = params[:host_name]
#    custom_env= params[:software_environment_variables]
#    #   custom_env=params
#    @core_api = core_api
#    @http_protocol = params[:http_protocol]
#    p params
#    @repoName= params[:repository_url]
#    @cron_job_list = Array.new
#    @build_name = File.basename(@repoName).sub(/\.git$/,"")
#    @workerPorts=Array.new
#    @webPort=8000
#    @vols=Array.new

  #FIXME Kludge
  def get_container_network_metrics(containerName)
    begin
      ret_val = Hash.new
      clear_error
      cmd = "docker exec " + containerName + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 " " $6}'  2>&1"
      res= %x<#{cmd}>
      vals = res.split("bytes:")
      if vals.count < 2
        if vals[1] != nil && vals[2] != nil
          ret_val[:in] = vals[1].chop
          ret_val[:out] = vals[2].chop
        else
          ret_val[:in] ="-1"
          ret_val[:out] ="-1"
        end
      else
        ret_val[:in] ="-1"
        ret_val[:out] ="-1"
      end
      return ret_val
    rescue Exception=>e
      log_exception(e)
      ret_val[:in] = -1
      ret_val[:out] = -1
      return ret_val
    end
  end

  def is_startup_complete container
    clear_error
    begin
      return @system_api.is_startup_complete(container)
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end

  protected

  def get_volbuild_volmaps container
    begin
      clear_error
      state_dir = SysConfig.CidDir + "/containers/" + container.containerName + "/run/"
      log_dir = SysConfig.SystemLogRoot + "/containers/" + container.containerName
      volume_option = " -v " + state_dir + ":/client/state:rw "
      volume_option += " -v " + log_dir + ":/client/log:rw "
      if container.volumes != nil
        container.volumes.each_value do |vol|
          SystemUtils.debug_output vol
          volume_option += " -v " + vol.localpath.to_s + ":/dest/fs:rw"
        end
      end
      volume_option += " --volumes-from " + container.containerName
      return volume_option
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clear_error
    @last_error = ""
  end

  def log_exception(e)
    e_str = e.to_s()
    e.backtrace.each do |bt |
      e_str += bt
    end
    @last_error = e_str
    SystemUtils.log_output(e_str,10)
  end

end

