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

  def add_domain(params)
    return  @system_api.add_domain(params)
  end

  #
  #  def remove_containers_cron_list(container_name)
  #    p :remove_containers_cron
  #    if @system_api.remove_containers_cron_list(container_name)
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

  #  def add_monitor(site_hash)
  #    return @system_api.add_monitor(site_hash)
  #  end
  #
  #  def rm_monitor(site_hash)
  #    return @system_api.rm_monitor(site_hash)
  #  end

  def get_build_report(engine_name)
    return @system_api.get_build_report(engine_name)
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

#  def load_system_preferences
#    return @system_api.load_system_preferences
#  end
#
#  def save_system_preferences(preferences)
#    return @system_api.save_system_preferences(preferences)
#  end

  def get_container_memory_stats(container)
    return @system_api.get_container_memory_stats(container)
  end

  def set_engine_hostname_details(container,params)
    return @system_api.set_engine_hostname_details(container,params)
  end

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

  def setup_email_params(params)

    arg="smarthost_hostname=" + params[:smarthost_hostname] \
    + ":smarthost_username=" + params[:smarthost_username]\
    + ":smarthost_password=" + params[:smarthost_password]\
    + ":mail_name=smtp."  + params[:default_domain]
    container=loadManagedService("smtp")
    return @docker_api.docker_exec(container,SysConfig.SetupParamsScript,arg)
  rescue   Exception=>e
    SystemUtils.log_exception(e)
  end

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
    @system_preferences.set_default_site(params)
    
  end

  def get_default_site()
    @system_preferences.get_default_site
  end
  
  def get_default_domain()
    @system_preferences.get_default_domain
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
    SystemUtils.log_exception(e)
    return false
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

    if service_hash.has_key?(:variables) == false
      log_error_mesg("Attached Service passed no variables",service_hash)
      return false
    end

    sm = loadServiceManager()
    if sm.add_service(service_hash)
      return sm.register_service_hash_with_service(service_hash) 
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
    return sm.remove_service(params)
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

  def find_engine_services(params)
    sm = loadServiceManager()
    return sm.find_engine_services(params)
  end

  def load_service_definition(filename)

    yaml_file = File.open(filename)
    #    p :open
    #    p filename
    return  SoftwareServiceDefinition.from_yaml(yaml_file)
  rescue
  rescue Exception=>e
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

  def get_orphaned_services_tree
    return loadServiceManager.get_orphaned_services_tree
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

        @system_api.destroy_container(container)  #removes cid file
        return true
      else
        return false
      end
    rescue Exception=>e
      container.last_error=( "Failed To Destroy " + e.to_s)
      SystemUtils.log_exception(e)

      return false

    end
  end

  def generate_engines_user_ssh_key
    return @system_api.regen_system_ssh_key
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
      service_hash[:remove_all_application_data]  = params[:remove_all_application_data]
      if service_hash.has_key?(:service_container_name) == false
        log_error_mesg("Missing :service_container_name in service_hash",service_hash)
        return false
      end
      service = loadManagedService(service_hash[:service_container_name])
      if service == nil
        log_error_mesg("Failed to load container name keyed by :service_container_name ",service_hash)
        return false
      end
      if service.is_running == false
        log_error_mesg("Cannot remove service consumer if service is not running ",service_hash)
        return false
      end
      if service.remove_consumer(service_hash) == false

        log_error_mesg("Failed to remove service ",service_hash)
        return false
      end
      #REMOVE THE SERVICE HERE AND NOW
      if sm.remove_from_engine_registery(service_hash) ==true
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
      command = "docker run --name volbuilder --memory=20m -e fw_user=" + username + " --cidfile /opt/engines/run/volbuilder.cid " + mapped_vols + " -t engines/volbuilder:" + SystemUtils.system_release + " /bin/sh /home/setup_vols.sh "
      SystemUtils.debug_output("Run volumen builder",command)
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
      SystemUtils.log_exception(e)

      return false
    end
  end
def load_and_attach_persistant_services(container)
    dirname = get_container_dir(container) + "/persistant/"
  sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container )
  end
  

  def load_and_attach_nonpersistant_services(container)
    dirname = get_container_dir(container) + "/nonpersistant/"
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container)
  end

  def get_container_dir(container)
    return @system_api.container_state_dir(container) +"/services/"
  end


  #install from fresh copy of blueprint in repositor
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

  #FIXME Kludge
  def get_container_network_metrics(container_name)
    begin
      ret_val = Hash.new
      clear_error
      cmd = "docker exec " + container_name + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 " " $6}'  2>&1"
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
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
      return false
    end
  end

  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)

    @last_error = msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)

  end

  def register_non_persistant_services(engine_name)
    sm = loadServiceManager()
    return sm.register_non_persistant_services(engine_name)
  end


  def deregister_non_persistant_services(engine_name)
    sm = loadServiceManager()
    return sm.deregister_non_persistant_services(engine_name)
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
  def delete_service_from_service_registry(service_hash)
    sm = loadServiceManager()
       return sm.remove_from_services_registry(service_hash)
  end

    def delete_service_from_engine_registry(service_hash)
      sm = loadServiceManager()
            return sm.remove_from_engine_registery(service_hash)
    end
  protected

  def get_volbuild_volmaps container
    begin
      clear_error
      state_dir = SysConfig.CidDir + "/containers/" + container.container_name + "/run/"
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

