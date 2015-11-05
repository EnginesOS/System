require '/opt/engines/lib/ruby/system/system_config.rb'
require '/opt/engines/lib/ruby/system/system_utils.rb'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
require '/opt/engines/lib/ruby/containers/managed_engine.rb'
require '/opt/engines/lib/ruby/containers/managed_service.rb'
require '/opt/engines/lib/ruby/containers/system_service.rb'
require '/opt/engines/lib/ruby/managed_services/system_services/volume_service.rb'
require '/opt/engines/lib/ruby/managed_services/service_definitions/software_service_definition.rb'
require '/opt/engines/lib/ruby/service_manager/service_manager.rb'
require '/opt/engines/lib/ruby/service_manager/service_definitions.rb'
require '/opt/engines/lib/ruby/api/public/engines_osapi_result.rb'

class EnginesCore < ErrorsApi
  require '/opt/engines/lib/ruby/api/public/build_controller.rb'
  require '/opt/engines/lib/ruby/system/dnshosting.rb'
  require_relative 'containers/container_api.rb'
  require_relative 'containers/service_api.rb'
  require_relative 'docker/docker_api.rb'
  require_relative 'system_api.rb'
  require_relative 'dns_api.rb'
  require_relative 'registry_handler.rb'
  require_relative 'configurations_api.rb'
  require_relative 'blueprint_api.rb'
  require_relative 'system_preferences.rb'
  require_relative 'memory_statistics.rb'
  def initialize
    Signal.trap('HUP', proc { api_shutdown })
    Signal.trap('TERM', proc { api_shutdown })
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  # will change to to docker_api and not self
    @registry_handler = RegistryHandler.new(@system_api)
    @container_api = ContainerApi.new(@docker_api, @system_api, self)
    @service_api = ServiceApi.new(@docker_api, @system_api, self)
    @registry_handler.start
  end
  
  attr_reader :container_api, :service_api

  def check_hash(service_hash)
    return log_error_mesg('Nil service Hash', service_hash) if service_hash.nil?
    return log_error_mesg('Not a Service Hash', service_hash) unless service_hash.is_a?(Hash)  
    return true
  end
  
  def check_service_hash(service_hash)
    return false unless check_hash(service_hash)
    return log_error_mesg('No publisher name space', service_hash) unless service_hash.key?(:publisher_namespace)
    return log_error_mesg('nil publisher name space', service_hash) if service_hash[:publisher_namespace].nil? || service_hash[:publisher_namespace] == ''
    return log_error_mesg('No type path', service_hash) unless service_hash.key?(:type_path)
    return log_error_mesg('nil type path', service_hash) if service_hash[:type_path].nil? || service_hash[:type_path] == ''
    
    return true
  end
  
  def check_engine_hash(service_hash)
    return false unless check_hash(service_hash)
    # FIXME: Kludge
    # Klugde to avoid gui bugss
    unless service_hash.key?(:parent_engine)
      service_hash[:parent_engine] = service_hash[:engine_name]
    end
    service_hash[:container_type] = "container" unless service_hash.key?(:container_type) 
    # End of Kludge
    return log_error_mesg('No parent engine', service_hash) unless service_hash.key?(:parent_engine)
    return log_error_mesg('nil parent_engine', service_hash) if service_hash[:parent_engine].nil? || service_hash[:parent_engine] == ''
    return log_error_mesg('No container type path', service_hash) unless service_hash.key?(:container_type)
    return log_error_mesg('nil container type path', service_hash)  if service_hash[:container_type].nil? || service_hash[:container_type] == ''
    return true
  end
  
  def check_sub_service_hash(service_hash)
    return false unless check_service_hash(service_hash)
    return log_error_mesg('No parent service', service_hash) unless service_hash.key?(:parent_service)
    return true
  end
  
  def check_engine_service_hash(service_hash)
      return false unless check_engine_service_query(service_hash)
    return log_error_mesg('No service variables', service_hash) unless service_hash.key?(:variables)
      return true
    end
    
  def check_engine_service_query(service_hash)
       return false unless check_service_hash(service_hash)
     return false unless check_engine_hash(service_hash)  
    return true
     end
      
  
  def taken_hostnames
    query= {}
      query[:type_path]='nginx'
      query[:publisher_namespace] = "EnginesSystem"
        
      
    sites = []
    hashes = service_manager.all_engines_registered_to('nginx')
    return sites if hashes == false
    hashes.each do |service_hash|   
      sites.push(service_hash[:variables][:fqdn])
    end
    return sites
    rescue StandardError => e
       log_exception(e)
  end
  
  def api_shutdown
    p :BEING_SHUTDOWN
 
    @registry_handler.api_shutdown
  end
  
  def get_registry_ip
    @registry_handler.get_registry_ip
  end

  def force_registry_restart
    log_error_mesg("Forcing registry restart ", nil)
    @registry_handler.force_registry_restart
  end

  def software_service_definition(params)
    clear_error
    return false unless check_service_hash(params)
    return SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )
  rescue StandardError => e
    p :error
    p params
    log_exception(e)
    return nil
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(service_hash)
    clear_error
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.get_registered_against_service(service_hash))
  end

  def update_attached_service(service_hash)
    clear_error
    return false unless check_engine_service_hash(service_hash)
    check_sm_result(service_manager.update_attached_service(service_hash))
  end

  def signal_service_process(pid, sig, name)
    clear_error
    container = loadManagedService(name)
    test_docker_api_result(@docker_api.signal_container_process(pid, sig, container))
  end

  def get_build_report(engine_name)
    @system_api.get_build_report(engine_name)
  end

  def restart_system
    test_system_api_result(@system_api.restart_system)
  end
  
    def restart_system
        test_system_api_result(@system_api.restart_mgmt)
      end
      
  def update_engines_system_software
    test_system_api_result(@system_api.update_engines_system_software)
  end

  def update_system
    test_system_api_result(@system_api.update_system)
  end

  def save_build_report(container,build_report)
    test_system_api_result(@system_api.save_build_report(container,build_report))
  end

  def image_exist?(container_name)
    test_docker_api_result(@docker_api.image_exist?(container_name))
  rescue StandardError => e
    log_exception(e)
  end

  def list_attached_services_for(objectName, identifier)
    check_sm_result(service_manager.list_attached_services_for(objectName, identifier))
  rescue StandardError => e
    log_exception(e)
  end

  def list_avail_services_for(object)
    objectname = object.class.name.split('::').last
    services = load_avail_services_for(objectname)
    subservices = load_avail_component_services_for(object)
    retval = {}
    retval[:services] = services
    retval[:subservices] = subservices
    return retval
  rescue StandardError => e
    log_exception(e)
  end

  def load_software_service(params)
    service_container = check_sm_result(ServiceDefinitions.get_software_service_container_name(params))
    params[:service_container_name] = service_container
    loadManagedService(service_container)
  rescue StandardError => e
    log_exception(e)
  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = 'echo -e ' + pass + "\n" + pass + ' | passwd engines'
    SystemUtils.debug_output('ssh_pw', cmd)
    SystemUtils.run_system(cmd)
  end

  def set_default_domain(params)
    preferences = SystemPreferences.new
    preferences.set_default_domain(params)
  end

  def set_default_site(params)
    service_param = {}
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    service_param[:vaiables] = {}
    service_param[:vaiables][:default_site_url] = params[:default_site_url]
    update_service_configuration(service_param)
  end

  def get_default_site()
    service_param = {}
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    config_params = retrieve_service_configuration(service_param)
    if config_params.is_a?(Hash) == true && config_params.key?(:variables) == true
      vars = config_params[:variables]
      return vars[:default_site_url] if vars.key?(:default_site_url)
    end
    return ''
  end

  def get_default_domain()
    preferences = SystemPreferences.new
    preferences.get_default_domain
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
    service_hash = SystemUtils.symbolize_keys(service_hash)
    p :attach_ing
    p service_hash
    return false unless check_engine_service_hash(service_hash)
    return log_error_mesg('Attached Service passed no variables', service_hash) unless service_hash.key?(:variables)
    return log_error_mesg('register failed', service_hash) unless check_sm_result(service_manager.add_service(service_hash))
        if service_hash[:type_path] == 'filesystem/local/filesystem'       
        engine = loadManagedEngine(service_hash[:parent_engine])
        return log_error_mesg('No such Engine',service_hash) unless engine.is_a?(ManagedEngine)
      engine.add_volume(service_hash)
          end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def remove_orphaned_service(service_hash)
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.remove_orphaned_service(service_hash))
  rescue StandardError => e
    log_exception(e)
  end

  def dettach_service(service_hash)
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.delete_service(service_hash))
  rescue StandardError => e
    log_exception(e)
  end

  def list_providers_in_use
    check_sm_result(service_manager.list_providers_in_use)
  end

  def service_manager
    @service_manager = ServiceManager.new(self) unless @service_manager.is_a?(ServiceManager)
    return @service_manager
  end

  #returns
  def find_service_consumers(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.find_service_consumers(service_query))
  end

  def  service_is_registered?(service_hash)
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.service_is_registered?(service_hash))
  end

  def get_engine_persistant_services(service_hash)
    return false unless check_engine_hash(service_hash)
    check_sm_result(service_manager.get_engine_persistant_services(service_hash))
  end

  def managed_service_tree
    check_sm_result(service_manager.managed_service_tree)
  end

  def get_managed_engine_tree
    check_sm_result(service_manager.get_managed_engine_tree)
  end

  def web_sites_for(container)
    clear_error
    urls = []
    params = {}
    params[:parent_engine] = container.container_name
    if container.ctype == 'container'
      params[:container_type] = 'container'
    else
      params[:container_type] = 'service'
    end
    params[:publisher_namespace]='EnginesSystem'
    params[:type_path]='nginx'
    sites = find_engine_services(params)
    return urls if sites.is_a?(Array) == false
    sites.each do |site|      
    p site.to_s unless  site.is_a?(Hash)  
      next unless site.is_a?(Hash) && site[:variables].is_a?(Hash)
      if site[:variables][:proto] == 'http_https'
        protocol = 'https'
      else
        protocol = site[:variables][:proto]
        protocol = 'http' if protocol.nil?
      end
      url = protocol.to_s + '://' + site[:variables][:fqdn].to_s
      urls.push(url)
    end
    return urls
  end
  
    # @ returns  complete service hash matching PNS,SP,PE,SH
     def retrieve_service_hash(query_hash)
       check_sm_result(service_manager.find_engine_service_hash(query_hash))
     end

  def find_engine_services(service_query)
    return false unless check_engine_hash(service_query)
    check_sm_result(service_manager.find_engine_services_hashes(service_query))
    #return sm.find_engine_services(params)
  end

  def get_configurations_tree
    check_sm_result(service_manager.service_configurations_tree)
  end

  def load_service_definition(filename)
    yaml_file = File.open(filename)
    SoftwareServiceDefinition.from_yaml(yaml_file)
  rescue StandardError => e
    p :filename
    p filename
    log_exception(e)
  end

  def fillin_template_for_service_def(service_hash)
    return false unless check_service_hash(service_hash)
    service_def =  SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    container = loadManagedEngine(service_hash[:parent_engine])
    if container == false
      log_error_mesg('container load error', service_hash)
    end
    p :filling_in_template_on
    p container
    templater = Templater.new(SystemAccess.new, container)
    templater.fill_in_service_def_values(service_def)
    return service_def
  rescue StandardError => e
    p service_hash
    p service_def
    log_exception(e)
  end

    def get_resolved_string(env_value) 
      
      templater = Templater.new(SystemAccess.new,nil)
      env_value = templater.apply_system_variables(env_value)
         return env_value
       rescue StandardError => e

         log_exception(e)
       end
  
  def load_avail_services_for_type(typename)
    avail_services = []
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exist?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          if service_dir_entry.start_with?('.') == true
            next
          end
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            if service.nil? == false
              if service.is_a?(String)
                log_error_mesg('service yaml load error', service)
              else
                avail_services.push(service.to_h)
              end
            end
          end
        rescue StandardError => e
          log_exception(e)
          puts dir.to_s + '/' + service_dir_entry
          next
        end
      end
    end
    #p :avail_services
    #p avail_services.to_s
    return avail_services
  rescue StandardError => e
    log_exception(e)
  end

  def retrieve_service_configuration(config)
    c = ConfigurationsApi.new(self)
    r = c.retrieve_service_configuration(config)
    return log_error_mesg('Configration failed ' +  c.last_error, r) unless r.is_a?(Hash)
    return r
  end

  def update_service_configuration(service_param)
    configurator = ConfigurationsApi.new(self)
    return log_error_mesg('Configration failed', configurator.last_error) unless configurator.update_service_configuration(service_param)
    return log_error_mesg('Failed to update configuration with', service_manager.last_error) unless check_sm_result(service_manager.update_service_configuration(service_param))
    return true
  end

  def engine_persistant_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:persistant] = true
    params[:container_type] ='container'
      p :engine_persistant_services
      p params
    return check_sm_result(service_manager.get_engine_persistant_services(params))
  rescue StandardError => e
    log_exception(e)
  end

  def engine_attached_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:container_type] = 'container'
    return service_manager.find_engine_services_hashes(params)
  rescue StandardError => e
    log_exception(e)
  end

  def attach_subservice(service_query)
    return false unless check_sub_service_hash(service_query)
    return attach_service(service_query) # if params.key?(:parent_service) && params[:parent_service].key?(:publisher_namespace) && params[:parent_service].key?(:type_path)    && params[:parent_service].key?(:service_handle)
    log_error_mesg('missing parrameters', service_query)
  end

  def dettach_subservice(service_query)
    return false unless check_sub_service_hash(service_query)
    dettach_service(service_query) 
    log_error_mesg('missing parrameters', service_query)
  end

  def load_avail_services_for(typename)
    avail_services = []
    dir = SystemConfig.ServiceMapTemplateDir + '/' + typename
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        begin
          next if service_dir_entry.start_with?('.')
          if service_dir_entry.end_with?('.yaml')
            service = load_service_definition(dir + '/' + service_dir_entry)
            avail_services.push(service.to_h) if !service.nil?
          end
        rescue StandardError => e
          log_exception(e)
          next
        end
      end
    end
    return avail_services
  rescue StandardError => e
    log_exception(e)
  end

  def load_avail_component_services_for(engine)
    retval = {}
    if engine.is_a?(ManagedEngine)
      params = {}
      params[:engine_name] = engine.container_name
      persistant_services = get_engine_persistant_services(params)
      return nil if persistant_services.is_a?(FalseClass)
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
  rescue StandardError => e
    log_exception(e)
    return nil
  end

  def set_engine_runtime_properties(params)
    engine_name = params[:engine_name]
    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult)
      @last_error = engine.result_mesg
      return false
    end
    if engine.is_active?
      @last_error = 'Container is active'
      return false
    end
    if params.key?(:memory)
      if params[:memory] == engine.memory
        @last_error = 'No Change in Memory Value'
        return false
      end
      if engine.update_memory(params[:memory]) == false
        @last_error = engine.last_error
        return false
      end
    end
    if params.key?(:environment_variables)
      new_variables = params[:environment_variables]
      engine.environments.each do |env|
        # new_variables.each do |new_env|
        new_variables.each_pair do |new_env_name, new_env_value|
          if  env.name == new_env_name
            return log_error_mesg('Cannot Change Value of',env) if env.immutable
            env.value = new_env_value
          end
          # end
        end
      end
    end
    if engine.has_container?
      return log_error_mesg(engine.last_error,engine) if !engine.destroy_container
    end
    return log_error_mesg(engine.last_error,engine) if !engine.create_container
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def test_docker_api_result(result)
    @last_error = @docker_api.last_error if result.nil? || result.is_a?(FalseClass)
    return result
  end

  def test_system_api_result(result)
    @last_error = @system_api.last_error.to_s if result.is_a?(FalseClass)
    return result
  end

  #@returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    test_docker_api_result(@docker_api.pull_image(image_name))
  end

  def set_engine_network_properties (engine, params)
    test_system_api_result(@system_api.set_engine_network_properties(engine,params))
  end

  def getManagedEngines
    test_system_api_result(@system_api.getManagedEngines)
  end

  def get_container_network_metrics(engine_name)
    engine = test_system_api_result(@system_api.loadManagedEngine(engine_name))
    return engine.get_container_network_metrics if engine.is_a?(ManagedEngine)
    engine = test_system_api_result(@system_api.loadManagedService(engine_name))
    return engine.get_container_network_metrics if engine.is_a?(ManagedService)
    log_error_mesg("Failed to load network stats",engine_name)
  end

  def loadManagedEngine(engine_name)
    test_system_api_result(@system_api.loadManagedEngine(engine_name))
  end

  def get_orphaned_services_tree
    service_manager.get_orphaned_services_tree
  end

  def loadManagedService(service_name)
    test_system_api_result(@system_api.loadManagedService(service_name))
  end

  def getManagedServices
    test_system_api_result(@system_api.getManagedServices)
  end

  def add_domain(params)
    dns_api = DNSApi.new(service_manager)
    return true if dns_api.add_domain(params)
    log_error_mesg(dns_api.last_error, params)
  end

  def update_domain(params)
    dns_api = DNSApi.new(service_manager)
    return true if dns_api.update_domain(params)
    log_error_mesg(dns_api.last_error, params)
  end

  def remove_domain(params)
    dns_api = DNSApi.new(service_manager)
    return true if dns_api.remove_domain(params)
    log_error_mesg(dns_api.last_error, params)
  end

#  def list_domains
#    res = DNSApi.list_domains
#    return res if res.is_a?(Hash)
#    log_error_mesg(res, '')
#  end

  
  def list_managed_engines
    test_system_api_result(@system_api.list_managed_engines)
  end

  def list_managed_services
    test_system_api_result(@system_api.list_managed_services)
  end

  def generate_engines_user_ssh_key
    test_system_api_result(@system_api.regen_system_ssh_key)
  end

  def update_public_key(key)
    test_system_api_result(@system_api.update_public_key(key))
  end

  def generate_engines_user_ssh_key
    test_system_api_result(@system_api.generate_engines_user_ssh_key)
  end

  def system_update
    test_system_api_result(@system_api.update_system)
  end
  
   def enable_remote_exception_logging
     test_system_api_result(@system_api.enable_remote_exception_logging)
   end
    def disable_remote_exception_logging
      test_system_api_result(@system_api.disable_remote_exception_logging)
    end
  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistant service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful

  def delete_engine(params)
    params[:container_type] = 'container' # Force This
    return log_error_mesg('Failed to remove engine Services',params) unless delete_image_dependancies(params)
    engine_name = params[:engine_name]
    remove_engine(engine_name)
    return true
  end

  def remove_engine(engine_name)
    engine = loadManagedEngine(engine_name)
    params = {}
    params[:engine_name] = engine_name
    params[:container_type] = 'container' # Force This
    params[:parent_engine] =  engine_name 
    unless engine.is_a?(ManagedEngine) # used in roll back and only works if no engine do mess with this logic
      return true if service_manager.remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to find Engine',params)
    end
    if engine.delete_image || engine.has_image? == false
      p :engine_image_deleted    
      return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params) #remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
    end
    log_error_mesg('Failed to delete image',params)
  end

  def delete_image_dependancies(params)
    params[:parent_engine] = params[:engine_name]
    params[:container_type] = 'container'
      p :delete_image_dependancies
    p params
    return log_error_mesg('Failed to remove deleted Service',params) unless service_manager.rm_remove_engine_services(params)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def run_volume_builder(container,username)
    clear_error
    if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
      command = 'docker stop volbuilder'
      SystemUtils.run_system(command)
      command = 'docker rm volbuilder'
      SystemUtils.run_system(command)
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
    File.delete(SystemConfig.CidDir + '/volbuilder.cid') if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
    res = SystemUtils.run_system(command)
    SystemUtils.log_error(res) if res.is_a?(FalseClass)
    # don't return false as
    return true
  rescue StandardError => e
    log_exception(e)
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    engine.destroy_container if engine.has_container?
    params = {}
    params[:engine_name] = engine.container_name
    delete_engine(params)
    builder = BuildController.new(self)
    builder.reinstall_engine(engine)
  rescue  StandardError => e
    @last_error = e.to_s
    log_exception(e)
  end

  #  #rebuilds image from current blueprint
  #  def rebuild_image(container)
  #    clear_error
  #    params = {}
  #    params[:engine_name] = container.container_name
  #    params[:domain_name] = container.domain_name
  #    params[:host_name] = container.hostname
  #    params[:env_variables] = container.environments
  #    params[:http_protocol] = container.protocol
  #    params[:repository_url] = container.repo
  #    params[:software_environment_variables] = container.environments
  #    #   custom_env=params
  #    #  @http_protocol = params[:http_protocol] = container.
  #    builder = EngineBuilder.new(params, self)
  #    return builder.rebuild_managed_container(container)
  #  rescue StandardError => e
  #    log_exception(e)
  #  end

  #  def image_exist?(image_name)
  #    test_docker_api_result(@docker_api.image_exist?(image_name))
  #  end

  def force_reregister_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_reregister_attached_service(service_query))
  end

  def force_deregister_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_deregister_attached_service(service_query))
  end

  def force_register_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_register_attached_service(service_query))
  end

  #@return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
  #:path_type :publisher_namespace
  def get_orphaned_services(service_hash)
    return false unless check_service_hash(service_hash)
    service_manager.get_orphaned_services(service_hash)
  end

  def clean_up_dangling_images
    test_docker_api_result(@docker_api.clean_up_dangling_images)
  end

  def has_container_started?(container_name)
    completed_flag_file = SystemConfig.RunDir + '/containers/' + container_name + '/run/flags/startup_complete'
    File.exist?(completed_flag_file)
  end

  def check_sm_result(result)
    @last_error = service_manager.last_error.to_s  if result.nil? || result.is_a?(FalseClass)
    return result
  end

  protected

  def shutdown
    # FIXME: @registry_handler.api_dissconnect
    @system_api.api_shutdown
  end

  def get_volbuild_volmaps(container)
    clear_error
    state_dir = SystemConfig.RunDir + '/containers/' + container.container_name + '/run/'
    log_dir = SystemConfig.SystemLogRoot + '/containers/' + container.container_name
    volume_option = ' -v ' + state_dir + ':/client/state:rw '
    volume_option += ' -v ' + log_dir + ':/client/log:rw '
    unless container.volumes.nil?
      container.volumes.each_value do |vol|
        SystemUtils.debug_output('build vol maps', vol)
        volume_option += ' -v ' + vol.localpath.to_s + ':/dest/fs:rw'
      end
    end
    volume_option += ' --volumes-from ' + container.container_name
    return volume_option
  rescue StandardError => e
    log_exception(e)
  end

  # @return an [Array] of service_hashs of Active persistant services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistant_services(params)
    service_manager.get_active_persistant_services(params)
  end
end
