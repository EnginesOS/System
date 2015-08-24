require '/opt/engines/lib/ruby/system/system_config.rb'
require '/opt/engines/lib/ruby/system/system_utils.rb'
require '/opt/engines/lib/ruby/system/dnshosting.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
require '/opt/engines/lib/ruby/containers/managed_engine.rb'
require '/opt/engines/lib/ruby/managed_services/managed_service.rb'
require '/opt/engines/lib/ruby/managed_services/system_service.rb'
require '/opt/engines/lib/ruby/managed_services/system_services/volume_service.rb'
require '/opt/engines/lib/ruby/managed_services/service_definitions/software_service_definition.rb'
require '/opt/engines/lib/ruby/managed_services/service_manager/service_manager.rb'
require '/opt/engines/lib/ruby/engine_builder/engine_builder.rb'
require '/opt/engines/lib/ruby/api/public/engines_osapi_result.rb'
class EnginesCore

  require_relative 'docker_api.rb'
  require_relative 'system_api.rb'
  require_relative 'system_preferences.rb'
  def initialize
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  #will change to to docker_api and not self
    @system_preferences = SystemPreferences.new
    @last_error = String.new
  end

  attr_reader :last_error

  def software_service_definition(params)
    clear_error
  return    SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )
    rescue Exception=>e
      p :error
      p params
      log_exception(e)
      return nil
#    sm = loadServiceManager
#    return check_sm_result(sm.software_service_definition(params))
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    clear_error
    sm = loadServiceManager()
    return check_sm_result(sm.get_registered_against_service(params))
  end

  def update_attached_service(params)
    clear_error
    sm = loadServiceManager()
    return check_sm_result(sm.update_attached_service(params))
  end
  #  def add_domain(params)
  #    clear_error
  #    return  test_system_api_result(@system_api.add_domain(params))
  #  end

  def remove_domain(params)
    clear_error
    return test_system_api_result(@system_api.remove_domain(params[:domain_name]))
  end

  def update_domain(old_domain,params)
    clear_error
    params[:original_domain_name]=old_domain
    return test_system_api_result(@system_api.update_domain(params))
  end

  def signal_service_process(pid,sig,name)
    clear_error
    container = loadManagedService(name)
    return test_docker_api_result(@docker_api.signal_container_process(pid,sig,container))
  end

  def start_container(container)
    clear_error
    if container.dependant_on.is_a?(Array)
      start_dependancies(container)
    end
    return  test_docker_api_result(@docker_api.start_container(container))
  end

  def inspect_container(container)
    clear_error
    return  test_docker_api_result(@docker_api.inspect_container(container))
  end

  def stop_container(container)
    clear_error
    return test_docker_api_result(@docker_api.stop_container(container))
  end

  def pause_container(container)
    clear_error
    return  test_docker_api_result(@docker_api.pause_container(container))
  end

  def  unpause_container(container)
    return   test_docker_api_result(@docker_api.unpause_container(container))
  end

  def  ps_container(container)
    return  test_docker_api_result(@docker_api.ps_container(container))
  end

  def  logs_container(container)
    return  test_docker_api_result(@docker_api.logs_container(container))
  end

  def get_build_report(engine_name)
    return @system_api.get_build_report(engine_name)
  end

 

  def restart_system
    return test_system_api_result(@system_api.restart_system)
  end

  def update_engines_system_software
    test_system_api_result(@system_api.update_engines_system_software)
  end

  def update_system
    test_system_api_result(@system_api.update_system)
  end

  def save_build_report(container,build_report)
    return test_system_api_result(@system_api.save_build_report(container,build_report))
  end

  def save_container(container)
    return test_system_api_result(@system_api.save_container(container))
  end

  def save_blueprint(blueprint,container)
    return test_system_api_result(@system_api.save_blueprint(blueprint,container))
  end

  def load_blueprint(container)
    return test_system_api_result(@system_api.load_blueprint(container))
  end

#  def add_volume(site_hash)
#    return test_system_api_result(@system_api.add_volume(site_hash))
#  end
#
#  def rm_volume(site_hash)
#    return test_system_api_result(@system_api.rm_volume(site_hash))
#  end

  def get_container_memory_stats(container)
    return test_system_api_result(@system_api.get_container_memory_stats(container))
  end
  def get_container_network_metrics(container)
      return test_system_api_result(@system_api.get_container_network_metrics(container))
    end
  
  def image_exist?(container_name)
    imageName = container_name
    return test_docker_api_result(@docker_api.image_exist?(imageName))
  rescue Exception=>e
    log_exception(e)
    return false
  end

  def list_attached_services_for(objectName,identifier)
    sm = loadServiceManager()
    return check_sm_result(sm.list_attached_services_for(objectName,identifier))
  rescue Exception=>e
    log_exception e

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
    service_container =  check_sm_result(sm.get_software_service_container_name(params))
    params[:service_container_name] = service_container
    service = loadManagedService(service_container)
    if service == nil
      return nil
    end
    return service
  rescue Exception=>e
    log_exception e
  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = 'echo -e ' + pass + '\n' + pass + ' | passwd engines'
    SystemUtils.debug_output( 'ssh_pw',cmd)
    SystemUtils.run_system(cmd)
  end

  def set_default_domain(params)
    @system_preferences.set_default_domain(params)
  end

  def set_default_site(params)
    service_param = Hash.new
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    service_param[:vaiables] = Hash.new
    service_param[:vaiables][:default_site_url] = params[:default_site_url]
    update_service_configuration(service_param)
  end

  def get_default_site()
    service_param = Hash.new
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    config_params = retrieve_service_configuration(service_param)
    p config_params
    if config_params.is_a?(Hash) == true && config_params.has_key?(:variables) == true
      vars = config_params[:variables]
      if vars.has_key?(:default_site_url)
        return vars[:default_site_url]
      end
    end
    return ''
  end

  def get_default_domain()
    @system_preferences.get_default_domain
  end

  def container_type(container_name)
    if loadManagedEngine(container_name) != false
      return 'container'
    elsif loadManagedService(container_name) != false
      return 'service'
    else
      return 'container' #FIXME poor assumption
    end
  end

  #Attach the service defined in service_hash [Hash]
  #@return boolean indicating sucess
  def attach_service(service_hash)
    service_hash =  SystemUtils.symbolize_keys(service_hash)
    if service_hash == nil
      log_error_mesg('Attach Service passed a nil','')
      return false
    elsif service_hash.is_a?(Hash) == false
      log_error_mesg('Attached Service passed a non Hash',service_hash)
      return false
    end
    if service_hash.has_key?(:variables) == false
      log_error_mesg('Attached Service passed no variables',service_hash)
      return false
    end
    sm = loadServiceManager()
    if sm.add_service(service_hash)
      return check_sm_result(sm.add_service(service_hash))
    else
      log_error_mesg('register failed',  service_hash)
    end
    return false
  rescue Exception=>e
    log_exception e
  end

  def remove_orphaned_service(params)
    sm = loadServiceManager()
    check_sm_result(sm.remove_orphaned_service(params))
  rescue Exception=>e
    log_exception e
  end

  def dettach_service(params)
    sm = loadServiceManager()
    check_sm_result(sm.delete_service(params))
  rescue Exception=>e
    log_exception e
    return  false
  end
  
  def list_providers_in_use
    sm = loadServiceManager()
    return check_sm_result(sm.list_providers_in_use)
  end

  def loadServiceManager()
    if @service_manager == nil
      @service_manager = ServiceManager.new(self)
      return @service_manager
    end
    return @service_manager
  end

  def force_registry_restart
    #start in thread in case timeout clobbers
    registry_service = test_system_api_result(@system_api.loadSystemService('registry'))
 #FIXME need to panic if cannot load
    restart_thread = Thread.new {
      registry_service.stop_container
      registry_service.start_container
      while registry_service.is_startup_complete? == false
        sleep 1
        wait=wait+1
        if wait >60
          return force_registry_recreate
        end
      end
    }
    restart_thread.join
    return true
  end

  def force_registry_recreate
    registry_service = test_system_api_result(@system_api.loadSystemService('registry'))
    if registry_service.forced_recreate == false
      @last_error= 'Fatal Unable to Start Registry Service: ' + registry_service.last_error
      return false
    end
    return true
  end

  def get_registry_ip
    registry_service = test_system_api_result(@system_api.loadSystemService('registry'))
    case registry_service.read_state
    when 'nocontainer'
      registry_service.create_container
    when 'paused'
      registry_service.unpause_container
    when 'stopped'
      registry_service.start_container
    end
    if registry_service.read_state != 'running'
      if registry_service.forced_recreate == false
        @last_error= 'Fatal Unable to Start Registry Service: ' + registry_service.last_error
        return nil
      end
    end
    wait = 0
    while registry_service.is_startup_complete? == false
      sleep 1
      wait=wait+1
      if wait >60
        break
      end
    end

    return registry_service.get_ip_str
  rescue Exception=>e
    @last_error= 'Fatal Unable to Start Registry Service: ' + e.to_s
    log_exception e
  end

  def match_orphan_service(service_hash)
    sm = loadServiceManager()
    res =  check_sm_result( sm.retrieve_orphan(service_hash) )
    if res != nil && res != false
      return true
    end
    return false
  end

  #returns
  def find_service_consumers(params)
    sm = loadServiceManager()
    return check_sm_result(sm.find_service_consumers(params))
  end

  def  service_is_registered?(service_hash)
    sm = loadServiceManager()
    return check_sm_result(sm.service_is_registered?(service_hash))
  end

  def get_engine_persistant_services(params)
    sm = loadServiceManager()
    return check_sm_result(sm.get_engine_persistant_services(params))
  end

  def managed_service_tree
    sm = loadServiceManager()
    return check_sm_result(sm.managed_service_tree)
  end

  def get_managed_engine_tree
    sm = loadServiceManager()
    return check_sm_result(sm.get_managed_engine_tree)
  end

  def web_sites_for(container)
    urls = Array.new
    params = Hash.new()
    params[:parent_engine] = container.container_name
    if container.ctype == 'container'
      params[:container_type] = 'container'
    else
      params[:container_type] = 'service'
    end
    params[:publisher_namespace]='EnginesSystem'
    params[:type_path]='nginx'
    sites = find_engine_services(params)
    if sites.is_a?(Array) == false
      return urls
    end
    sites.each do |site|
      p :Site
      p site
      if site[:variables][:proto] ==     'http_https'
        protocol='https'
      else
        protocol=site[:variables][:proto]
      end
      url= protocol + '://' + site[:variables][:fqdn]
      urls.push(url)
    end
    return urls
  end

  def find_engine_services(params)
    sm = loadServiceManager()
    return check_sm_result(sm.find_engine_services_hashes(params))
    #return sm.find_engine_services(params)
  end

  def get_configurations_tree
    sm = loadServiceManager()
    return check_sm_result(sm.service_configurations_tree)
  end

  def load_service_definition(filename)
    yaml_file = File.open(filename)
    return  SoftwareServiceDefinition.from_yaml(yaml_file)
  rescue Exception=>e
    p :filename
    p filename
    log_exception e
  end

  def fillin_template_for_service_def(service_hash)
    service_def =  SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    container = loadManagedEngine(service_hash[:parent_engine])
    if container == false
      log_error_mesg('container load error',service_hash)
    end
    templater =  Templater.new(SystemAccess.new,container)
    templater.fill_in_service_def_values(service_def)
    return service_def

  rescue Exception=>e
    p service_hash
    p service_def
    log_exception e
  end

  def load_avail_services_for_type(typename)
    avail_services = Array.new

    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?('.')   == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            if service != nil
              if service.is_a?(String)
                log_error_mesg('service yaml load error',service)
              else
                avail_services.push(service.to_h)
              end
            end
          end
        rescue Exception=>e
          log_exception e
          puts  dir.to_s + '/' + service_dir_entry
          next
        end
      end
    end
    return avail_services
  rescue Exception=>e
    log_exception e
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
        @last_error = 'No Service'
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
      service_param[:publisher_namespace] = service.publisher_namespace.to_s
      service_param[:type_path] = service.type_path.to_s
      if service != false && service != nil
        configurator_result =  service.run_configurator(service_param)
        if configurator_result == false
          @last_error = 'Service configurator error ' + service.last_error.to_s
          return false
        end
        if configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning') == true
          if check_sm_result(sm.update_service_configuration(service_param)) == false
            p sm.last_error
            @last_error = sm.last_error
            return false
          end
          return true
        else
          @last_error = 'stderr' + configurator_result[:stderr] +  '  ' + configurator_result[:result].to_s
        end
      else
        @last_error = 'no Service'
      end
    end
    return false
  end

  def engine_persistant_services(container_name)
    sm = loadServiceManager()
    params = Hash.new()
    params[:parent_engine] = container_name
    params[:persistant] = true
    params[:container_type] ='container'
    return check_sm_result(sm.find_engine_services_hashes(params))
  rescue Exception=>e
    log_exception e
  end

  def engine_attached_services(container_name)
    sm = loadServiceManager()
    params = Hash.new()
    params[:parent_engine] = container_name
    params[:container_type] ='container'
    return sm.find_engine_services_hashes(params)
  rescue Exception=>e
    log_exception e
  end

  def attach_subservice(params)
    if  params.has_key?(:parent_service)    && params[:parent_service].has_key?(:publisher_namespace)     && params[:parent_service].has_key?(:type_path)    && params[:parent_service].has_key?(:service_handle)
      return attach_service(params)
    end
    @last_error = 'missing parrameters'
    return false
  end

  def dettach_subservice(params)
    if  params.has_key?(:parent_service)    && params[:parent_service].has_key?(:publisher_namespace)     && params[:parent_service].has_key?(:type_path)    && params[:parent_service].has_key?(:service_handle)
      return dettach_service(params)
    end
    @last_error = 'missing parrameters'
    return false
  end

  def load_avail_services_for(typename)
    avail_services = Array.new
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?('.')   == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            if service != nil

              avail_services.push(service.to_h)
            end
          end
        rescue Exception=>e
          log_exception e
          next
        end
      end
    end
    return avail_services
  rescue Exception=>e
    log_exception e
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
      end
    else
      p :load_avail_component_services_for_engine_got_a
      p engine.to_s
      return nil
    end
    return retval
  rescue Exception=>e
    log_exception e
    return nil
  end

  def set_engine_runtime_properties(params)
    engine_name = params[:engine_name]
    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult) == true
      @last_error = engine.result_mesg
      return false
    end
    if engine.is_active? == true
      @last_error='Container is active'
      return false
    end
    if params.has_key?(:memory)
      if params[:memory] == engine.memory
        @last_error='No Change in Memory Value'
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
              @last_error = 'Cannot Change Value of ' + env.name
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
    log_exception e
    return false
  end

  def test_docker_api_result(result)
    if result == nil || result == false
      @last_error =  @docker_api.last_error
    end
    return result
  end

  def test_system_api_result(result)
    if result == nil || result == false
      @last_error =  @system_api.last_error
    end
    return result
  end

  #@returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image (image_name)
    return test_docker_api_result(@docker_api.pull_image(image_name))
  end

  def set_engine_network_properties (engine, params)
    return test_system_api_result(@system_api.set_engine_network_properties(engine,params))
  end


  def getManagedEngines
    return test_system_api_result(@system_api.getManagedEngines)
  end

  def loadManagedEngine(engine_name)
    return test_system_api_result(@system_api.loadManagedEngine(engine_name))
  end

  def get_orphaned_services_tree
    return loadServiceManager.get_orphaned_services_tree
  end

  def loadManagedService(service_name)
    return test_system_api_result(@system_api.loadManagedService(service_name))
  end

  def getManagedServices
    return test_system_api_result(@system_api.getManagedServices)
  end

  def add_domain(params)
    return test_system_api_result(@system_api.add_domain(params))
  end

  def update_domain(params)
    return test_system_api_result(@system_api.update_domain(params))
  end

  def remove_domain(params)
    return test_system_api_result(@system_api.remove_domain(params))
  end

  def list_domains
    return test_system_api_result(@system_api.list_domains)
  end

  def list_managed_engines
    return test_system_api_result(@system_api.list_managed_engines)
  end

  def list_managed_services
    return test_system_api_result(@system_api.list_managed_services)
  end

  def destroy_container(container)
    clear_error
    begin
      if container.has_container? == true
        ret_val = test_docker_api_result(@docker_api.destroy_container(container))
      else
        ret_val = true
      end
      if ret_val == true
        ret_val = test_docker_api_result(@system_api.destroy_container(container))  #removes cid file
      end
      return ret_val
    rescue Exception=>e
      container.last_error=( 'Failed To Destroy ' + e.to_s)
      log_exception(e)
      return false
    end
  end

  def generate_engines_user_ssh_key
    return test_system_api_result(@system_api.regen_system_ssh_key)
  end

  def update_public_key(key)
    return test_system_api_result(@system_api.update_public_key(key))
  end

  def generate_engines_user_ssh_key
    return test_system_api_result(@system_api.generate_engines_user_ssh_key)
  end

  def system_update
    return test_system_api_result(@system_api.update_system)
  end

  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistant service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  
  def delete_engine(params)    
    params[:container_type]='container'
      
    if delete_image_dependancies(params) == false
      log_error_mesg('Failed to remove engine Services',params)
           return false
    end 
    engine_name = params[:engine_name]
    engine = loadManagedEngine(engine_name)
    sm = loadServiceManager()
    if engine.is_a?(ManagedEngine) == false
      if sm.remove_engine_from_managed_engines_registry(params) == true #used in roll back and only works if no engine do mess with this logic
           return true
      end
      log_error_mesg('Failed to  find Engine',params)
          return false
    end    
    if engine.delete_image == true
      if sm.remove_engine_from_managed_engines_registry(params) == true
      return true
      else
        log_error_mesg('Failed to remove Engine from engines registry '+sm.last_error.to_s,params)
         return false
      end
    end
    log_error_mesg('Failed to remove Engine',params)
     return false
  end
  
  def delete_image_dependancies(params)
    sm = loadServiceManager()
    params[:parent_engine] = params[:engine_name]
    params[:container_type]='container'
    if sm.rm_remove_engine_services(params) == false
      log_error_mesg('Failed to remove deleted Service',params)
      return false
    end
    return true
  rescue Exception=>e
    log_exception(e)
    return false
  end

  def run_system(cmd)
    clear_error
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemUtils.debug_output('run system',res)
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?('error') == false && res.downcase.include?('fail') == false && res.downcase.include?('could not resolve hostname') == false && res.downcase.include?('unsuccessful') == false
        return true
      else
        @last_error = res
        SystemUtils.debug_output('run system result',res)
        return false
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def run_volume_builder(container,username)
    clear_error
    begin
      if File.exists?(SystemConfig.CidDir + '/volbuilder.cid') == true
        command = 'docker stop volbuilder'
        run_system(command)
        command = 'docker rm volbuilder'
        run_system(command)
        File.delete(SystemConfig.CidDir + '/volbuilder.cid')
      end
      mapped_vols = get_volbuild_volmaps container
      command = 'docker run --name volbuilder --memory=12m -e fw_user=' + username + ' -e data_gid=' + container.data_gid + '   --cidfile ' +SystemConfig.CidDir + 'volbuilder.cid ' + mapped_vols + ' -t engines/volbuilder:' + SystemUtils.system_release + ' /bin/sh /home/setup_vols.sh '
      SystemUtils.debug_output('Run volume builder',command)
      p command
      #run_system(command)
      result = SystemUtils.execute_command(command)
      if result[:result] != 0
        p result[:stdout]
          @last_error='Volbuilder: ' + command + '->' + result[:stdout].to_s + ' err:' + result[:stderr].to_s
            p @last_error
          return false
      end
      #Note no -d so process will not return until setup.sh completes
      command = 'docker rm volbuilder'
      if File.exists?(SystemConfig.CidDir + '/volbuilder.cid') == true
        File.delete(SystemConfig.CidDir + '/volbuilder.cid')
      end
      res = run_system(command)
      if  res != true
        SystemUtils.log_error(res)
        #don't return false as
      end
      return true
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_container(container)
    clear_error
      if container.ctype != 'system_service' && container.has_container? == true
        container.last_error = 'Failed To create container exists by the same name'
        return false
      end
      test_system_api_result(@system_api.clear_cid_file(container))
      test_system_api_result(@system_api.clear_container_var_run(container))
      start_dependancies(container) if container.dependant_on.is_a?(Array)
      test_docker_api_result(@docker_api.pull_image(container.image)) if @ctype != 'container' 
      if  test_docker_api_result(@docker_api.create_container(container)) == true
        return test_system_api_result(@system_api.create_container(container))
      else
        return false
      end
    rescue Exception => e
      container.last_error = ('Failed To Create ' + e.to_s)
      log_exception(e)
      return false
  end

  def load_and_attach_persistant_services(container)
    dirname = get_container_services_dir(container) + '/pre/'
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container )
  end

  def load_and_attach_shared_services(container)
    dirname = get_container_services_dir(container) + '/shared/'
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container)
  end

  def load_and_attach_nonpersistant_services(container)
    dirname = get_container_services_dir(container) + '/post/'
    sm = loadServiceManager()
    return sm.load_and_attach_services(dirname,container)
  end

  def get_container_services_dir(container)
    return test_system_api_result(@system_api.container_state_dir(container)) +'/services/'
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    EngineBuilder.re_install_engine(engine,self)
  rescue  Exception=>e
    log_exception(e)
    @last_error=e.to_s
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
      log_exception(e)
      return false
    end
  end

  #  def image_exist?(image_name)
  #    test_docker_api_result(@docker_api.image_exist?(image_name))
  #  end


  def is_startup_complete container
    clear_error
    begin
      return test_system_api_result(@system_api.is_startup_complete(container))
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end

  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)
    @last_error = @last_error.to_s + ':' + msg +':' + obj_str
    SystemUtils.log_error_mesg(msg,object)
  end
  
  def log_exception(e)
    @last_error = @last_error.to_s + e.to_s
    p @last_error + e.backtrace.to_s
    return false
  end

  
  def force_reregister_attached_service(service_query)
    sm = loadServiceManager()
    return check_sm_result(sm.force_reregister_attached_service(service_query))
  end
def force_deregister_attached_service(service_query)
  sm = loadServiceManager()
  return check_sm_result(sm.force_deregister_attached_service(service_query))
end
def force_register_attached_service(service_query)
  sm = loadServiceManager()
  return check_sm_result(sm.force_register_attached_service(service_query))
end


#Called by Managed Containers
  def register_non_persistant_service(service_hash)
    sm = loadServiceManager()
    return check_sm_result(sm.register_non_persistant_service(service_hash))
  end

#Called by Managed Containers
  def deregister_non_persistant_service(service_hash)
    sm = loadServiceManager()
    return check_sm_result(sm.deregister_non_persistant_service(service_hash))
  end

#Called by Managed Containers
  def register_non_persistant_services(engine)
    sm = loadServiceManager()
    return check_sm_result(sm.register_non_persistant_services(engine))
  end

#Called by Managed Containers
  def deregister_non_persistant_services(engine)
    sm = loadServiceManager()
    return check_sm_result(sm.deregister_non_persistant_services(engine))
  end

  #@return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
  #:path_type :publisher_namespace
  def get_orphaned_services(params)
    return loadServiceManager.get_orphaned_services(params)
  end

  def clean_up_dangling_images
    test_docker_api_result(@docker_api.clean_up_dangling_images)
  end

  def  start_dependancies(container)
    container.dependant_on.each do |service_name|
      service = loadManagedService(service_name)
      if service == false
        @last_error = 'Failed to load ' + service_name
        return false
      end
      if service.is_running? != true
        if service.has_container? == true
          if service.is_active? == true
            if service.unpause_container == false
              @last_error = 'Failed to unpause ' + service_name
              return false
            end
          elsif service.start_container == false
            @last_error = 'Failed to start ' + service_name
            return false
          end
        elsif service.create_container == false
          @last_error = 'Failed to create ' + service_name
          return false
        end
      end
      retries=0
      while  has_service_started?(service_name) == false
        sleep 10
        retries+=1
        if retries >3
          log_error_mesg('Time out in waiting for Service Dependancy ' + service_name + ' to start ',service_name)

          return false
        end
      end
    end
    return true
  end

  def has_container_started?(container_name)
    completed_flag_file= SystemConfig.RunDir + '/containers/' + container_name + '/run/flags/startup_complete'
    return File.exist?(completed_flag_file)
  end

  def has_service_started?(service_name)
    completed_flag_file= SystemConfig.RunDir + '/services/' + service_name + '/run/flags/startup_complete'
    return File.exist?(completed_flag_file)
  end

  def check_system_api_result(result)
    if result == nil || result == false
      @last_error = @system_api.last_error.to_s[0,128]
    end
    return result
  end

  def check_sm_result(result)
    if result == nil || result.is_a?(FalseClass)
      sm = loadServiceManager()
      @last_error = sm.last_error
    end
    return result
  end


def delete_image(container)
  begin
    clear_error
    if test_docker_api_result(@docker_api.delete_image(container)) == true
      #only delete if del all otherwise backup
      return  test_system_api_result(@system_api.delete_container_configs(container))
    end
    #NO Image well delete the rest
    if test_docker_api_result(@docker_api.image_exist?(container.image)) == false
      test_system_api_result( @system_api.delete_container_configs(container))
    end
    return true
  rescue Exception=>e
    @last_error=( 'Failed To Delete ' + e.to_s)
    log_exception(e)
    return false
  end
end
private 
#def delete_engine_persistant_services(params)
#    sm = loadServiceManager()
#    services = check_sm_result(sm.get_engine_persistant_services(params))
#    services.each do |service_hash|
#      service_hash[:remove_all_data]  = params[:remove_all_data]
#      if service_hash.has_key?(:service_container_name) == false
#        log_error_mesg('Missing :service_container_name in service_hash',service_hash)
#        return false
#      end
#      service = loadManagedService(service_hash[:service_container_name])
#      if service == nil
#        log_error_mesg('Failed to load container name keyed by :service_container_name ',service_hash)
#        return false
#      end
#      if service.is_running? == false
#        log_error_mesg('Cannot remove service consumer if service is not running ',service_hash)
#        return false
#      end
#      if service.remove_consumer(service_hash) == false
#        log_error_mesg('Failed to remove service ',service_hash)
#        return false
#      end
#      #REMOVE THE SERVICE HERE AND NOW
#      if sm.remove_from_engine_registry(service_hash) ==true
#        if sm.remove_from_services_registry(service_hash) == false
#          log_error_mesg('Cannot remove from Service Registry',service_hash)
#          return false
#        end
#      else
#        log_error_mesg('Cannot remove from Engine Registry',service_hash)
#        return false
#      end
#    end
#    return true
#  rescue Exception=>e
#    @last_error=( 'Failed To Delete ' + e.to_s)
#    log_exception(e)
#    return false
#  end

  protected

  def get_volbuild_volmaps container
    begin
      clear_error
      state_dir = SystemConfig.RunDir + '/containers/' + container.container_name + '/run/'
      log_dir = SystemConfig.SystemLogRoot + '/containers/' + container.container_name
      volume_option = ' -v ' + state_dir + ':/client/state:rw '
      volume_option += ' -v ' + log_dir + ':/client/log:rw '
      if container.volumes != nil
        container.volumes.each_value do |vol|
          SystemUtils.debug_output('build vol maps',vol)
          volume_option += ' -v ' + vol.localpath.to_s + ':/dest/fs:rw'
        end
      end
      volume_option += ' --volumes-from ' + container.container_name
      return volume_option
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clear_error
    @last_error = ''
  end

  #@return an [Array] of service_hashs of Active persistant services match @params [Hash]
  #:path_type :publisher_namespace
  def get_active_persistant_services(params)
    return loadServiceManager.get_active_persistant_services(params)
  end
end

