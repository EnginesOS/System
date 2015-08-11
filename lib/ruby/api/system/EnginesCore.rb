class EnginesCore

  require "/opt/engines/lib/ruby/system/SystemUtils.rb"
  require "/opt/engines/lib/ruby/system/DNSHosting.rb"
  require_relative 'DockerApi.rb'
  require_relative 'SystemApi.rb'
  require_relative 'SystemPreferences.rb'

  def initialize
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  #will change to to docker_api and not self
    @system_preferences = SystemPreferences.new
    @last_error = String.new
  end

  attr_reader :last_error

  def software_service_definition(params)
    sm = loadServiceManager
    return sm.software_service_definition(params)
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    sm = loadServiceManager
    return sm.get_registered_against_service(params)
  end

  def update_attached_service(params)
    sm = loadServiceManager()
    return sm.update_attached_service(params)
  end 
  def add_domain(params)
    return  @system_api.add_domain(params)
  end

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
    if container.dependant_on.is_a?(Array)
        start_dependancies(container)
    end
    return  @docker_api.start_container(container)
  end

  def inspect_container(container)
    return  @docker_api.inspect_container(container)
  end

  def stop_container(container)
    return @docker_api.stop_container(container)
  end

  def pause_container(container)
    return  @docker_api.pause_container(container)
  end

  def  unpause_container(container)
    return   @docker_api.unpause_container(container)
  end

  def  ps_container(container)
    return  @docker_api.ps_container(container)
  end

  def  logs_container(container)
    return  @docker_api.logs_container(container)
  end

  def get_build_report(engine_name)
    return @system_api.get_build_report(engine_name)
  end
  
  def restart_system 
    return @system_api.restart_system
  end
  def update_engines_system_software
    @system_api.update_engines_system_software
  end 
  def update_system    
    @system_api.update_system
  end
  def save_build_report(container,build_report)
    return @system_api.save_build_report(container,build_report)
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
#
#  def remove_self_hosted_domain(domain_name)
#    return @system_api.remove_self_hosted_domain(domain_name)
#  end
#
#  def add_self_hosted_domain(params)
#    return @system_api.add_self_hosted_domain(params)
#  end
#
#  def list_self_hosted_domains()
#    return @system_api.list_self_hosted_domains()
#  end
#
#  def  update_self_hosted_domain(old_domain_name, params)
#    @system_api.update_self_hosted_domain(old_domain_name, params)
#  end

  def get_container_memory_stats(container)
    return @system_api.get_container_memory_stats(container)
  end

  #  def set_engine_hostname_details(container,params)
  #    return @system_api.set_engine_hostname_details(container,params)
  #  end

  def image_exists?(container_name)
    imageName = container_name
    return @docker_api.image_exists?(imageName)
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def list_attached_services_for(objectName,identifier)
    sm = loadServiceManager()
    return sm.list_attached_services_for(objectName,identifier)
  rescue Exception=>e
    SystemUtils.log_exception e

  end

  def list_avail_services_for(object)
    objectname = object.class.name.split('::').last
    #    p :load_vail_services_for
    #    p objectname

    services = load_avail_services_for(objectname)

    subservices = load_avail_component_services_for(object)

    retval = Hash.new
    retval[:services] = services
    retval[:subservices] = subservices
    return retval
  rescue Exception=>e
    SystemUtils.log_exception e
  end

  def load_software_service(params)

    sm = loadServiceManager()
    #    p :load_software_service
    #    p params
    service_container =  sm.get_software_service_container_name(params)
    params[:service_container_name] = service_container
    #    p :service_container_name
    #    p service_container
    service = loadManagedService(service_container)
    if service == nil
      return nil
    end

    return service
  rescue Exception=>e
    SystemUtils.log_exception e
  end

#  def setup_email_params(params)
#
#    arg="smarthost_hostname=" + params[:smarthost_hostname] \
#    + ":smarthost_username=" + params[:smarthost_username]\
#    + ":smarthost_password=" + params[:smarthost_password]\
#    + ":mail_name=smtp."  + params[:default_domain]
#    container=loadManagedService("smtp")
#    return @docker_api.docker_exec(container,SysConfig.SetupParamsScript,arg)
#  rescue   Exception=>e
#    SystemUtils.log_exception(e)
#  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = "echo -e " + pass + "\n" + pass + " | passwd engines"
    SystemUtils.debug_output( "ssh_pw",cmd)
    SystemUtils.run_system(cmd)

  end

  def set_default_domain(params)
    @system_preferences.set_default_domain(params)
  end

  def set_default_site(params)
    service_param = Hash.new
    service_param[:service_name] = "nginx"
          service_param[:configurator_name] = "default_site"
    service_param[:vaiables] = Hash.new
    service_param[:vaiables][:default_site_url] = params[:default_site_url]
         config_params = update_service_configuration(service_param)

  end

  def get_default_site()
    
    service_param = Hash.new
      service_param[:service_name] = "nginx"
      service_param[:configurator_name] = "default_site"
     config_params = retrieve_service_configuration(service_param)
     p config_params
     if config_params.is_a?(Hash) == true && config_params.has_key?(:variables) == true
        vars = config_params[:variables]
          if vars.has_key?(:default_site_url)
            p :DEFAUL_SITE
            p vars[:default_site_url]
            return vars[:default_site_url]
          end
     end
     return ""
  end

  def get_default_domain()
    #    p :get_default_domain
    #    p @system_preferences.get_default_domain
    @system_preferences.get_default_domain
  end

#  def set_database_password(container_name,params)
#    arg = "mysql_password=" + params[:mysql_password] +":" \
#    + "server=" + container_name + ":" \
#    +  "psql_password=" + params[:psql_password] #Need two args
#    if container_name
#      server_container = loadManagedService(container_name)
#      return @docker_api.docker_exec(server_container,SysConfig.SetupParamsScript,arg)
#    end
#
#    return true
#
#  rescue Exception=>e
#    SystemUtils.log_exception(e)
#    return false
#  end

  def container_type(container_name)
    if loadManagedEngine(container_name) != false
      return "container"
    elsif loadManagedService(container_name) != false
      return "service"
    else
      return "container" #FIXME poor assumption
    end
  end

  #Attach the service defined in service_hash [Hash]
  #@return boolean indicating sucess
  def attach_service(service_hash)
    p :attach_Service
    p service_hash

    service_hash =  SystemUtils.symbolize_keys(service_hash)

    if service_hash == nil
      log_error_mesg("Attach Service passed a nil","")
      return false
    elsif service_hash.is_a?(Hash) == false
      log_error_mesg("Attached Service passed a non Hash",service_hash)
      return false
    end

    if service_hash.has_key?(:service_handle) == false || service_hash[:service_handle] == nil
      service_handle_field = SoftwareServiceDefinition.service_handle_field(service_hash)

      service_hash[:service_handle] = service_hash[:variables][service_handle_field.to_sym]
    end

    if service_hash.has_key?(:container_type) == false
      service_hash[:container_type] = container_type(service_hash[:parent_engine])
    end

    if service_hash.has_key?(:variables) == false
      log_error_mesg("Attached Service passed no variables",service_hash)
      return false
    end

    sm = loadServiceManager()
    if sm.add_service(service_hash)
      return sm.register_service_hash_with_service(service_hash)
    else
      log_error_mesg("register failed",  service_hash)
    end
    return false
  rescue Exception=>e
    SystemUtils.log_exception e
  end

  def remove_orphaned_service(params)
    sm = loadServiceManager()
    return sm.remove_orphaned_service(params)
  rescue Exception=>e
    SystemUtils.log_exception e
  end

  def dettach_service(params)
    sm = loadServiceManager()
    return sm.delete_service(params)
    #    if service !=nil && service != false
    #      return service.remove_consumer(params)
    #    end
    #    @last_error = "Failed to dettach Service: " + @last_error

  rescue Exception=>e
    SystemUtils.log_exception e
    return  false
  end

  def list_providers_in_use
    sm = loadServiceManager()
    return sm.list_providers_in_use
  end

  def loadServiceManager()
    if @service_manager == nil
      @service_manager = ServiceManager.new(self)
      return @service_manager
    end
    return @service_manager
  end

  def force_registry_restart
    
    registry_service.stop_container
    registry_service.start_container
    while registry_service.is_startup_complete? == false
      sleep 1
      wait=wait+1
        if wait >5
          break
        end
    end

  end
  def get_registry_ip
    registry_service = @system_api.loadSystemService("registry")
    case registry_service.read_state
    when "nocontainer"
      registry_service.create_service
    when "paused"
      registry_service.unpause_container
    when "stopped"   
      registry_service.start_container
    end
    if registry_service.read_state != "running"
      if registry_service.forced_recreate == false
        @last_error= "Fatal Unable to Start Registry Service: " + registry_service.last_error
        return nil
      end
    end
    wait = 0  
    while registry_service.is_startup_complete? == false
      sleep 1
      wait=wait+1
        if wait >5
          break
        end
    end

    return registry_service.get_ip_str
    rescue Exception=>e
    @last_error= "Fatal Unable to Start Registry Service: " + e.to_s
       SystemUtils.log_exception e
  end
  
  def match_orphan_service(service_hash)
    sm = loadServiceManager()

    if sm.retrieve_orphan(service_hash) == false
      return false
    end
    return true
  end

  #returns
  def find_service_consumers(params)
    sm = loadServiceManager()
    return sm.find_service_consumers(params)
  end

  def  service_is_registered?(service_hash)
    sm = loadServiceManager()
    return sm.service_is_registered?(service_hash)
  end

  def get_engine_persistant_services(params)
    sm = loadServiceManager()
    return sm.get_engine_persistant_services(params)
  end

  def managed_service_tree
    sm = loadServiceManager()
    return sm.managed_service_tree
  end

  def get_managed_engine_tree
    sm = loadServiceManager()
    return sm.get_managed_engine_tree
  end

  def web_sites_for(container)
    urls = Array.new
    params = Hash.new()
    params[:parent_engine] = container.container_name
      if container.ctype == "container"
          params[:container_type] = "container"
      else
        params[:container_type] = "service"
      end
      params[:publisher_namespace]="EnginesSystem"
      params[:type_path]="nginx"
        
      sites = find_engine_services(params)
      if sites.is_a?(Array) == false
        return urls
      end
        sites.each do |site|
          p :Site
          p site
       if site[:variables][:proto] ==     "http_https"              
          protocol="https"
       else
         protocol=site[:variables][:proto]
        end
        url= protocol + "://" + site[:variables][:fqdn]
         urls.push(url)
        end
        
        return urls
  end
  
  def find_engine_services(params)
    sm = loadServiceManager()
    return sm.find_engine_services_hashes(params)
    #return sm.find_engine_services(params)
  end

  def get_configurations_tree
    sm = loadServiceManager()
        return sm.service_configurations_tree
  end
  
  def load_service_definition(filename)

    yaml_file = File.open(filename)
    p :open
    p filename
    return  SoftwareServiceDefinition.from_yaml(yaml_file)

  rescue Exception=>e
    p :filename
    p filename
    SystemUtils.log_exception e
  end

  def fillin_template_for_service_def(service_hash)

    service_def =  SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    container = loadManagedEngine(service_hash[:parent_engine])
      if container == false
        log_error_mesg("container load error",service_hash)
      end
    templater =  Templater.new(SystemAccess.new,container)
    templater.fill_in_service_def_values(service_def)
    return service_def

  rescue Exception=>e
    p service_hash
    p service_def
    SystemUtils.log_exception e
  end

  def load_avail_services_for_type(typename)
    #    p :load_avail_services_for_by_type
    #    p typename
    retval = Array.new

    dir = SysConfig.ServiceMapTemplateDir + "/" + typename
    #    p :dir
    #    p dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?(".")   == true
            next
          end
          #          p :service_dir_entry
          #          p service_dir_entry
          if service_dir_entry.end_with?(".yaml")
            service = load_service_definition(dir + "/" + service_dir_entry)
            if service != nil
              #              p :service_as_serivce
              #              p service
              #              p :as_hash
              #              p service.to_h
              #              p :as_yaml
              #              p service.to_yaml()
              if service.is_a?(String)
                log_error_mesg("service yaml load error",service)
              else
                retval.push(service.to_h)
              end
            end
          end
        rescue Exception=>e
          SystemUtils.log_exception e
          puts  dir.to_s + "/" + service_dir_entry
          next
        end
      end
    end
    #    p typename
    #    p retval
    return retval
  rescue Exception=>e
    SystemUtils.log_exception e
  end

  def retrieve_service_configuration(service_param)
    if service_param.has_key?(:service_name)
      service = loadManagedService(service_param[:service_name])
        
      if service != false && service != nil
        retval =  service.retrieve_configurator(service_param)
          if retval.is_a?(Hash) == false
            return false
          end
      else
        @last_error = "No Service"
        return false
      end
    end
    @last_error = retval[:stderr]
    return retval
  end

  def update_service_configuration(service_param)

    if service_param.has_key?(:service_name)
      service = loadManagedService(service_param[:service_name])
      sm = loadServiceManager()
      sm.update_service_configuration(service_param)
      
      if service != false && service != nil
        retval =  service.run_configurator(service_param)
        if retval == false
          @last_error = "Service not running"
          return false
        end
        if retval[:result] == 0
          
          return true
        else
          @last_error = "stderr" + retval[:stderr] +  "  " + retval[:result].to_s
        end
      else
        @last_error = "no Service"
      end
    end
    return false
  end
  

def engine_persistant_services(container_name)
  sm = loadServiceManager()
  params = Hash.new()
  params[:parent_engine] = container_name
  params[:persistant] = true 
     return sm.find_engine_services_hashes(params)
   rescue Exception=>e
     SystemUtils.log_exception e
end

  def engine_attached_services(container_name)
    sm = loadServiceManager()
    params = Hash.new()
    params[:parent_engine] = container_name
       return sm.find_engine_services_hashes(params)
     rescue Exception=>e
       SystemUtils.log_exception e
  end

  def attach_subservice(params)
    if  params.has_key?(:parent_service)    && params[:parent_service].has_key?(:publisher_namespace)     && params[:parent_service].has_key?(:type_path)    && params[:parent_service].has_key?(:service_handle)
      return attach_service(params)
    end
    @last_error = "missing parrameters"
    return false
  end

  def dettach_subservice(params)
    if  params.has_key?(:parent_service)    && params[:parent_service].has_key?(:publisher_namespace)     && params[:parent_service].has_key?(:type_path)    && params[:parent_service].has_key?(:service_handle)
      return dettach_service(params)
    end
    @last_error = "missing parrameters"
    return false
  end

  def load_avail_services_for(typename)
    #    p :load_avail_services_for
    #    p typename
    retval = Array.new

    dir = SysConfig.ServiceMapTemplateDir + "/" + typename
    #    p :dir
    #    p dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?(".")   == true
            next
          end
          #          p :service_dir_entry
          #          p service_dir_entry
          if service_dir_entry.end_with?(".yaml")
            service = load_service_definition(dir + "/" + service_dir_entry)
            if service != nil

              retval.push(service.to_h)
            end
          end
        rescue Exception=>e
          SystemUtils.log_exception e
          next
        end
      end
    end
    #    p typename
    #    p retval
    return retval
  rescue Exception=>e
    SystemUtils.log_exception e
  end

  def load_avail_component_services_for(engine)
    retval = Hash.new
    if engine.is_a?(ManagedEngine)
      params = Hash.new
      params[:engine_name]=engine.container_name

      persistant_services =  get_engine_persistant_services(params)
      persistant_services.each do |service|
        type_path = service[:type_path]
        retval[type_path] = load_avail_services_for_type(type_path)
        #          p retval[type_path]
      end
    else
      #      p :load_avail_component_services_for_engine_got_a
      #      p engine.to_s
      return nil
    end
    return retval
  rescue Exception=>e
    SystemUtils.log_exception e
    return nil
  end

#  def reload_dns
#    dns_pid = File.read(SysConfig.NamedPIDFile)
#    dns_service = loadManagedService("dns")
#    return @docker_api.signal_container_process(dns_pid.to_s,'HUP',dns_service)
#  rescue  Exception=>e
#    SystemUtils.log_exception(e)
#    return false
#  end

  def set_engine_runtime_properties(params)

    engine_name = params[:engine_name]

    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult) == true
      @last_error = engine.result_mesg
      return false
    end

    if engine.is_active? == true
      @last_error="Container is active"
      return false
    end

    if params.has_key?(:memory)
      if params[:memory] == engine.memory
        @last_error="No Change in Memory Value"
        return false
      end

      if engine.update_memory(params[:memory]) == false
        @last_error= engine.last_error
        return false
      end
    end

    if params.has_key?(:environment_variables)
      new_variables = params[:environment_variables]
      #update_environment(engine,params[:environment_variables])
        p :new_varables
      p new_variables
      engine.environments.each do |env|
       # new_variables.each do |new_env|
        new_variables.each_pair  do | new_env_name, new_env_value |
          if  env.name == new_env_name
            if env.immutable == true
              @last_error = "Cannot Change Value of " + env.name
              return false
            end
            env.value =  new_env_value
          end
        # end
        end
      end
    end

    if engine.has_container? == true
      if destroy_container(engine)  == false
        @last_error= engine.last_error
        return false
      end
    end

    if  engine.create_container == false
      @last_error= engine.last_error
      return false
    end

    return true
    rescue Exception=>e
      SystemUtils.log_exception e
      return false
  end
  
 #@returns [Boolena]
 # whether pulled or no false if no new image 
 def pull_image 
    return @docker_api.pull_image(image_name)   
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

  def get_orphaned_services_tree
    return loadServiceManager.get_orphaned_services_tree
  end

  def loadManagedService(service_name)
    return @system_api.loadManagedService(service_name)
  end

  
  def getManagedServices
    return @system_api.getManagedServices
  end

   def add_domain(params)
     return @system_api.add_domain(params)
   end
def update_domain(params)
  return @system_api.update_domain(params)
end 
 def remove_domain(params)
   return @system_api.remove_domain(params)
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
      if container.has_container? == true
        ret_val = @docker_api.destroy_container(container)
      else
        retval = true
      end
      if ret_val == true
        ret_val = @system_api.destroy_container(container)  #removes cid file
      end

      return ret_val

    rescue Exception=>e
      container.last_error=( "Failed To Destroy " + e.to_s)
      SystemUtils.log_exception(e)

      return false

    end
  end

  def generate_engines_user_ssh_key
    return @system_api.regen_system_ssh_key
  end
  def update_public_key(key)
    return @system_api.update_public_key(key)
  end
def generate_engines_user_ssh_key
  return @system_api.generate_engines_user_ssh_key
end

  def system_update
    return @system_api.system_update
  end

  def delete_image(container)
    begin
      clear_error

      if @docker_api.delete_image(container) == true
        #only delete if del all otherwise backup
        return  @system_api.delete_container_configs(container)
      end

      #NO Image well delete the rest
      if @docker_api.image_exists?(container.image) == false
        return  @system_api.delete_container_configs(container)
      end

      return false

    rescue Exception=>e
      @last_error=( "Failed To Delete " + e.to_s)
      SystemUtils.log_exception(e)
      return false

    end
  end

  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistant service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine_persistant_services(params)
    sm = loadServiceManager()
    services = sm.get_engine_persistant_services(params)

    services.each do |service_hash|
      service_hash[:remove_all_data]  = params[:remove_all_data]
      if service_hash.has_key?(:service_container_name) == false
        log_error_mesg("Missing :service_container_name in service_hash",service_hash)
        return false
      end
      service = loadManagedService(service_hash[:service_container_name])
      if service == nil
        log_error_mesg("Failed to load container name keyed by :service_container_name ",service_hash)
        return false
      end
      if service.is_running? == false
        log_error_mesg("Cannot remove service consumer if service is not running ",service_hash)
        return false
      end
      if service.remove_consumer(service_hash) == false

        log_error_mesg("Failed to remove service ",service_hash)
        return false
      end
      #REMOVE THE SERVICE HERE AND NOW
      if sm.remove_from_engine_registry(service_hash) ==true
        if sm.remove_from_services_registry(service_hash) == false
          log_error_mesg("Cannot remove from Service Registry",service_hash)
          return false
        end
      else
        log_error_mesg("Cannot remove from Engine Registry",service_hash)
        return false
      end
    end
    return true

  rescue Exception=>e
    @last_error=( "Failed To Delete " + e.to_s)
    SystemUtils.log_exception(e)
    return false

  end

  def delete_image_dependancies(params)

    sm = loadServiceManager()
    params[:parent_engine] = params[:engine_name]
    if sm.rm_remove_engine(params) == false
      log_error_mesg("Failed to remove deleted Service",params)
      return false
    end

    return true

  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def run_system(cmd)
    clear_error
    begin
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>
      SystemUtils.debug_output("run system",res)
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
        return true
      else
        @last_error = res
        SystemUtils.debug_output("run system result",res)
        return false
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
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
      command = "docker run --name volbuilder --memory=4m -e fw_user=" + username + " -e data_gid=" + container.data_gid + "   --cidfile " +SysConfig.CidDir + "volbuilder.cid " + mapped_vols + " -t engines/volbuilder:" + SystemUtils.system_release + " /bin/sh /home/setup_vols.sh "
      SystemUtils.debug_output("Run volume builder",command)
      run_system(command)

      #Note no -d so process will not return until setup.sh completes

      command = "docker rm volbuilder"
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      res = run_system(command)
      if  res != true
        SystemUtils.log_error(res)
        #don't return false as
      end
      return true
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def create_container(container)
    clear_error
    begin
      if container.has_container? == true
        container.last_error="Failed To create container exists by the same name"
        return false
      end
      if @system_api.clear_cid_file(container) != false
        @system_api.clear_container_var_run(container)
        if container.dependant_on.is_a?(Array)
                start_dependancies(container)
            end
        if  @docker_api.create_container(container) == true
          return @system_api.create_container(container)
        end
      else
        return false
      end
    rescue Exception=>e
      container.last_error=("Failed To Create " + e.to_s)
      SystemUtils.log_exception(e)

      return false
    end
  end

  def load_and_attach_persistant_services(container)
    dirname = get_container_services_dir(container) + "/pre/"
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container )
  end
def load_and_attach_shared_services(container)
   dirname = get_container_services_dir(container) + "/shared/"
   sm = loadServiceManager()
   return sm.load_and_attach_services(dirname,container)
 end
  def load_and_attach_nonpersistant_services(container)
    dirname = get_container_services_dir(container) + "/post/"
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container)
  end

  def get_container_services_dir(container)
    return @system_api.container_state_dir(container) +"/services/"
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    EngineBuilder.re_install_engine(engine,self)
  rescue  Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  #rebuilds image from current blueprint
  def rebuild_image(container)
    clear_error
    begin
      params=Hash.new
      params[:engine_name] = container.container_name
      params[:domain_name] = container.domain_name
      params[:host_name] = container.hostname
      params[:env_variables] = container.environments
      params[:http_protocol] = container.protocol
      params[:repository_url]  = container.repo
      params[:software_environment_variables] = container.environments
      #   custom_env=params
      #  @http_protocol = params[:http_protocol] = container.
      builder = EngineBuilder.new(params, self)
      return  builder.rebuild_managed_container(container)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  #FIXME Kludge should read from network namespace /proc ?
  def get_container_network_metrics(container_name)
    begin
      ret_val = Hash.new
      clear_error
      def error_result
        ret_val = Hash.new
        ret_val[:in]="n/a"
        ret_val[:out]="n/a"
        return ret_val
      end

      commandargs="docker exec " + container_name + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 \" \" $6}'  2>&1"
      result = SystemUtils.execute_command(commandargs)
      p result
      if result[:result] != 0

        ret_val = error_result
      else
        res = result[:stdout]
        vals = res.split("bytes:")
        p res
        p vals
        if vals.count > 2
          if vals[1] != nil && vals[2] != nil
            ret_val[:in] = vals[1].chop
            ret_val[:out] = vals[2].chop
          else
            ret_val = error_result
          end
        else
          ret_val = error_result
        end
        p ret_val
        return ret_val
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)

      return   error_result
    end
  end

  def is_startup_complete container
    clear_error
    begin
      return @system_api.is_startup_complete(container)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)

    @last_error = msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)

  end
  def register_non_persistant_service(service_hash)
    sm = loadServiceManager()
       return sm.register_non_persistant_service(service_hash)
     end
def deregister_non_persistant_service(service_hash)
  sm = loadServiceManager()
     return sm.deregister_non_persistant_service(service_hash)
   end
  def register_non_persistant_services(engine)
    sm = loadServiceManager()
    return sm.register_non_persistant_services(engine)
  end

  def deregister_non_persistant_services(engine)
    sm = loadServiceManager()
    return sm.deregister_non_persistant_services(engine)
  end

  #@return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
  #:path_type :publisher_namespace
  def get_orphaned_services(params)
    return loadServiceManager.get_orphaned_services(params)
  end

  def clean_up_dangling_images
    @docker_api.clean_up_dangling_images
  end

  #@ return [Boolean] indicating sucess
  #For Maintanence ONLY
#  def delete_service_from_service_registry(service_hash)
#    sm = loadServiceManager()
#    return sm.remove_from_services_registry(service_hash)
#  end

  def delete_service_from_engine_registry(service_hash)
    sm = loadServiceManager()
    return sm.rm_remove_engine(service_hash)
  end
  
 def  start_dependancies(container)
   container.dependant_on.each do |service_name|
     service = loadManagedService(service_name)
     if service == false
       @last_error = "Failed to load " + service_name
       return false
     end
     if service.is_running? != true
       if service.has_container? == true
         if service.is_active? == true
           if service.unpause_container == false
             @last_error = "Failed to unpause " + service_name
             return false
            end
         elsif service.start_container == false
             @last_error = "Failed to start " + service_name
             return false            
         end
     elsif service.create_container == false
       @last_error = "Failed to create " + service_name
        return false
       end
     end
  
   
   retries=0
   
   while  has_service_started?(service_name) == false
     sleep 10
     retries+=1
      if retries >3
        log_error_mesg("Time out in waiting for Service Dependancy " + service_name + " to start ",service_name)
          
        return false
      end
   end
 end
   
   return true
 end
  
 def has_container_started?(container_name)
   completed_flag_file= SysConfig.RunDir + "/containers/" + container_name + "/run/flags/startup_complete"
      return File.exist?(completed_flag_file)
 end
 def has_service_started?(service_name)
   completed_flag_file= SysConfig.RunDir + "/services/" + service_name + "/run/flags/startup_complete"
    return File.exist?(completed_flag_file)
   
 end
       
  protected

  def get_volbuild_volmaps container
    begin
      clear_error
      state_dir = SysConfig.RunDir + "/containers/" + container.container_name + "/run/"
      log_dir = SysConfig.SystemLogRoot + "/containers/" + container.container_name
      volume_option = " -v " + state_dir + ":/client/state:rw "
      volume_option += " -v " + log_dir + ":/client/log:rw "
      if container.volumes != nil
        container.volumes.each_value do |vol|
          SystemUtils.debug_output("build vol maps",vol)
          volume_option += " -v " + vol.localpath.to_s + ":/dest/fs:rw"
        end
      end
      volume_option += " --volumes-from " + container.container_name
      return volume_option
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def clear_error
    @last_error = ""
  end

  #@return an [Array] of service_hashs of Active persistant services match @params [Hash]
  #:path_type :publisher_namespace
  def get_active_persistant_services(params)
    return loadServiceManager.get_active_persistant_services(params)
  end

end

