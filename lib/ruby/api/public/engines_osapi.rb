require '/opt/engines/lib/ruby/api/system/engines_core.rb'
require '/opt/engines/lib/ruby/api/system/system_status.rb'
require '/opt/engines/lib/ruby/system/system_config.rb'

require_relative 'engines_osapi_result.rb'
require_relative 'first_run_wizard.rb'

class EnginesOSapi
  require_relative 'build_controller.rb'

  attr_reader :core_api, :last_error

  require_relative 'engines_api_version.rb'
  include EngOSapiVersion
  def initialize
    @core_api = EnginesCore.new
  end

  def log_exception_and_fail(cmd, e)
    e_str = SystemUtils.log_exception(e)
    failed('Exception', e_str, cmd)
  end

  def self.log_exception_and_fail(cmd, e)
    e_str = SystemUtils.log_exception(e)
    failed('Exception', e_str, cmd)
  end

  def first_run_required?
    FirstRunWizard.required?
  end
  
  def reserved_engine_names
    names = list_apps
    names.concat(list_services)
    names.concat(list_system_services)
  end
  
  def list_system_services
    services = []
    services.push('registry')
    return services
  end
  
  def reserved_hostnames
     @core_api.taken_hostnames
  end
  

  # Build stuff
  def build_engine(params)
    build_controller = BuildController.new(@core_api)
    engine = build_controller.build_engine(params)
    return engine if engine.is_a?(EnginesOSapiResult)
    return failed(params[:engine_name], 'Failed to start  ' + engine.last_error, 'build_engine') unless engine.is_active?
    success(params[:engine_name], 'Build Engine')
  end

  def buildEngine(repository, host, domain_name, environment)
    build_controller = BuildController.new(@core_api)
    engine = build_controller.buildEngine(repository, host, domain_name, environment)
    return engine if engine.is_a?(EnginesOSapiResult)
    return failed(host.to_s, 'Failed to start  ' + engine.last_error.to_s, 'build_engine') unless engine.is_active?
    success(host.to_s + '.' + domain_name.to_s, 'Build Engine')
  end

  def rebuild_engine_container(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Load Engine Blueprint') if engine.is_a?(EnginesOSapiResult)
    state = engine.read_state
    return failed(engine_name, 'Cannot rebuild a container in State:' + state, 'Rebuild Engine') if state == 'running' || state == 'paused'
    retval = engine.rebuild_container
    return success(engine_name, 'Rebuild Engine Image') if retval.is_a?(ManagedEngine)
    failed(engine_name, 'Cannot rebuild Image:' + engine.last_error, 'Rebuild Engine')
  rescue StandardError => e
    log_exception_and_fail('Rebuild Engine', e)
  end

  def build_engine_from_docker_image(params)
    p params[:host_name]
    success(params[:host_name], 'Build Engine from Docker Image')
  rescue StandardError => e
    log_exception_and_fail('Build Engine from dockerimage', e)
  end

  def get_engine_build_report(engine_name)
    @core_api.get_build_report(engine_name)
  end

  def generate_private_key
      @core_api.generate_engines_user_ssh_key
  end

  def update_public_key(key)
    return success('Access', 'update public key') if @core_api.update_public_key(key)
    failed('Failed update key ', @core_api.last_error, key.to_s)
  end

  def get_system_ca
    File.read(SystemConfig.EnginesInternalCA)
  rescue StandardError => e
    failed('Failed to load CA', e.to_s, 'system ca')
  end

  def upload_ssl_certifcate(params)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return failed('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
    success('Access', 'upload Cert' + params[:domain_name])
  end

  # @return EngineOSapiResult
  # set the default Domain used by the system in creating new engines and for services that use web
  def set_default_domain(params)
    return success('Preferences', 'Set Default Domain') if @core_api.set_default_domain(params)
    failed('Preferences', @core_api.last_error, 'Set Default Domain')
  end

  # @return String
  # get the default Domain used by the system in creating new engines and for services that use web
  def get_default_domain
    @core_api.get_default_domain
  end

  #
  # @return boolean
  #   #set the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
  def set_default_site(params)
    return success('Preferences', 'Set Default Site') if @core_api.set_default_site(params)
    failed('Preferences', @core_api.last_error, 'Set Default Site')
  end

  # @return String
  # get the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
  def get_default_site
    @core_api.get_default_site
  end

  def set_first_run_parameters(params_from_gui)
    params = params_from_gui.dup
    p params
    first_run = FirstRunWizard.new(params)
    first_run.apply(@core_api)
    return success('Gui', 'First Run') if first_run.sucess
    failed('Gui', 'First Run', first_run.error.to_s)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    failed('Gui', 'First Run', 'failed')
  end

  def last_api_error
    return @core_api.last_error if @core_api
    return 'no Core!'
  rescue StandardError => e
    log_exception_and_fail('last_api_error', e)
  end

  def list_apps
    @core_api.list_managed_engines
  rescue StandardError => e
    log_exception_and_fail('list_apps', e)
  end

  def getManagedEngines
    @core_api.getManagedEngines
  rescue StandardError => e
    log_exception_and_fail('getManagedEngines', e)
  end

  def loadManagedEngine(engine_name)
    engine = @core_api.loadManagedEngine(engine_name)
    return engine if engine.is_a?(ManagedEngine)
    failed(engine_name, last_api_error, 'Load Engine')
  rescue StandardError => e
    log_exception_and_fail('loadManagedEngine', e)
  end

  def recreateEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Stop') if engine.recreate_container
    failed(engine_name, 'No Engine', 'Stop')
  rescue StandardError => e
    log_exception_and_fail('recreateEngine', e)
  end

  def stopEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Stop') if engine.stop_container
    failed(engine_name, 'No Engine', 'Stop')
  rescue StandardError => e
    log_exception_and_fail('stopEngine', e)
  end

  def startEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Start') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Start') if engine.start_container
    failed(engine_name, engine.last_error, 'Start')
  rescue StandardError => e
    log_exception_and_fail('startEngine', e)
  end

  def pauseEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Pause') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Pause') if engine.pause_container
    failed(engine_name, engine.last_error, 'Pause')
  rescue StandardError => e
    log_exception_and_fail('startEngine', e)
  end

  def unpauseEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Unpause') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'unpause') if engine.unpause_container
    failed(engine_name, engine.last_error, 'Unpause')
  rescue StandardError => e
    return log_exception_and_fail('unpause', e)
  end

  def destroyEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Destroy') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Destroy') if engine.destroy_container
    failed(engine_name, engine.last_error, 'Destroy')
  rescue StandardError => e
    log_exception_and_fail('Destroy', e)
  end

  def deleteEngineImage(params)
    return failed(params.to_s, 'no Engine name', 'Delete') if params.key?(:engine_name) == false || params[:engine_name].nil?
    engine = loadManagedEngine(params[:engine_name])
    return failed(params[:engine_name], 'no Engine', 'Delete') if engine.is_a?(EnginesOSapiResult)
    return success(params[:engine_name], 'Delete') if @core_api.delete_engine(params)
    failed(params[:engine_name], last_api_error, 'Delete Image ')
  rescue StandardError => e
    log_exception_and_fail('Delete', e)
  end

  def reinstall_engine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    
    return success(engine_name, 'Re Installed') if @core_api.reinstall_engine(engine).is_a?(ManagedEngine)
    failed(engine_name, @core_api.last_error, 'Reinstall Engine Failed')
  end
  
  def createEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Create') if engine.create_container
    failed(engine_name, engine.last_error, 'Create')
  rescue StandardError => e
    log_exception_and_fail('Create', e)
  end

  def restartEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Restart') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Restart') if engine.restart_container
    failed(engine_name, engine.last_error, 'Restart')
  rescue StandardError => e
    log_exception_and_fail('Restart', e)
  end

  def restart_system
    return success('System', 'System Restarting') if @core_api.restart_system
    failed('System', 'not permitted', 'System Restarting')
  end

  def update_engines_system_software
    return success('System', @core_api.last_error) if @core_api.update_engines_system_software
    failed('System', @core_api.last_error, 'Engines System Updating')
  end

  def update_system
    return success('System', 'System Updating') if @core_api.update_system
    failed('System', 'not permitted', 'Updating')
  end

  def get_engine_blueprint(engine_name)
    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult)
      return failed(engine_name, 'no Engine', 'Load Engine Blueprint')
    end
    retval = engine.load_blueprint
    if retval == false
      return failed(engine_name, engine.last_error, 'Load Engine Blueprint')
    end
    return retval
  rescue StandardError => e
    log_exception_and_fail('Load Engine Blueprint', e)
  end

  # not needed as inherited ???
  def read_state(container)
    container.read_state
  rescue StandardError => e
    log_exception_and_fail('read_state', e)
  end

  def get_system_memory_info
    SystemStatus.get_system_memory_info
  rescue StandardError => e
    log_exception_and_fail('get_system_memory_info', e)
  end

  def get_system_load_info
    SystemStatus.get_system_load_info
  rescue StandardError => e
    log_exception_and_fail('get_system_load_info', e)
  end

  def get_engine_memory_statistics(engine_name)
    mengine = loadManagedEngine(engine_name)
    if mengine.is_a?(EnginesOSapiResult)
      return failed(engine_name, 'no Engine', 'Get Engine Memory Statistics')
    end
    retval = mengine.get_container_memory_stats
    return retval
  rescue StandardError => e
    log_exception_and_fail('Get Engine Memory Statistics', e)
  end

  def get_service_memory_statistics(service_name)
    mservice = getManagedService(service_name)
    if mservice.is_a?(EnginesOSapiResult)
      return failed(service_name, 'no Engine', 'Get Service Memory Statistics')
    end
    retval = mservice.get_container_memory_stats
    return retval
  rescue StandardError => e
    log_exception_and_fail('Get Service Memory Statistics', e)
  end

  def get_container_network_metrics(container_name)
    @core_api.get_container_network_metrics(container_name)
  rescue StandardError => e
    log_exception_and_fail('get_container_network_metrics', e)
  end

  def set_engine_runtime_properties(params)
    if @core_api.set_engine_runtime_properties(params)
      return success(params[:engine_name], 'update engine runtime params')
    end
    return failed(params[:engine_name], @core_api.last_error, 'update engine runtime params')
  rescue StandardError => e
    log_exception_and_fail('set_engine_runtime params ', e)
  end

  def set_service_runtime_properties(params)
    return success(params[:engine_name], 'update service runtime params')
  rescue StandardError => e
    log_exception_and_fail('update service runtime params ', e)
  end

  def set_engine_network_properties(params)
    engine = loadManagedEngine(params[:engine_name])
    return engine if engine.instance_of?(EnginesOSapiResult)
    return failed('set_engine_network_details', last_api_error, 'set_engine_network_details') if engine.nil?
    return success(params[:engine_name], 'Update network details') if @core_api.set_engine_network_properties(engine, params)
    failed('set_engine_network_details', last_api_error, 'set_engine_network_details')
  end

  def update_domain(params)
    return success(params[:domain_name], 'update domain') if @core_api.update_domain(params)
    failed(params[:domain_name], last_api_error, 'update  domain')
  rescue StandardError => e
    log_exception_and_fail('update self hosted domain ' + params.to_s, e)
  end

  def add_domain(params)
    return success(params[:domain_name], 'Add domain') if @core_api.add_domain(params)
    failed(params[:domain_name], last_api_error, 'Add  domain')
  rescue StandardError => e
    log_exception_and_fail('Add self hosted domain ' + params.to_s, e)
  end

  def remove_domain(params)
    return success(params[:domain_name], 'Add domain') if @core_api.remove_domain(params)
    failed(params[:domain_name], last_api_error, 'Add  domain')
  rescue StandardError => e
    log_exception_and_fail('Add self hosted domain ' + params.to_s, e)
  end

  def list_domains
    @core_api.list_domains
  rescue StandardError => e
    log_exception_and_fail('list domains ', e)
  end

  # private ?
  # protected if protected static cant call
  def success(item_name, cmd)
    EnginesOSapiResult.success(item_name, cmd)
  end

  def failed(item_name, mesg, cmd)
    p :engines_os_api_fail_on
    p item_name
    p cmd
    p mesg.to_s + ':' + last_api_error.to_s
     EnginesOSapiResult.failed(item_name, mesg, cmd)
  end

  def self.failed(item_name, mesg, cmd)
    p :engines_os_api_fail_on_static
    p item_name
    p mesg + ':'
    p cmd
    EnginesOSapiResult.failed(item_name, mesg, cmd)
  end

  # @returns EnginesOSapiResult on sucess with private ssh key in repsonse messages
  def generate_engines_user_ssh_key
    return success('Engines ssh key regen', 'OK') if @core_api.generate_engines_user_ssh_key
    failed('Update System SSH key', @core_api.last_error, 'Update System SSH key')
  end

  # calls api to run system update
  # @return EnginesOSapiResult
  def system_update
    return success('System Update', "OK") if @core_api.system_update
    failed('System Update', @core_api.last_error, 'Update')
  end

  def createService(service_name)
    n_service = getManagedService(service_name)
    return failed(service_name, n_service.last_error, 'Create Service') if n_service.nil?
    return n_service if n_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Create Service') if n_service.create_service
    failed(service_name, n_service.last_error, 'Create Service')
  rescue StandardError => e
    log_exception_and_fail('Create Service', e)
  end

  def recreateService(service_name)
    rc_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Recreate Service') if rc_service.nil?
    return rc_service if rc_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Recreate Service') if rc_service.recreate
    failed(service_name, rc_service.last_error, 'Recreate Service')
  rescue StandardError => e
    return log_exception_and_fail('Recreate Service', e)
  end

  def list_services
    @core_api.list_managed_services
  rescue StandardError => e
    log_exception_and_fail('list_services', e)
  end

  def getManagedServices
    @core_api.getManagedServices
  rescue StandardError => e
    log_exception_and_fail('getManagedServices', e)
  end

  def self.loadManagedService(service_name, core_api)
    l_service = core_api.loadManagedService(service_name)
    return EnginesOSapi.failed(service_name, core_api.last_error, 'Load Service') unless l_service
    return l_service
  rescue StandardError => e
    EnginesOSapi.log_exception_and_fail('LoadMangedService', e)
  end

  def getManagedService(service_name)
    managed_service = @core_api.loadManagedService(service_name)
    return managed_service if managed_service.is_a?(ManagedService)
    p 'Fail to Load Service configuration:'
    p service_name
    failed(service_name, 'Fail to Load Service configuration:', service_name.to_s)
  rescue StandardError => e
    log_exception_and_fail('getManagedService', e)
  end

  def list_avail_services_for(object)
    @core_api.list_avail_services_for(object)
  end

  def find_service_consumers(params)
    @core_api.find_service_consumers(params)
  end

  def get_engine_persistant_services(params)
    @core_api.get_engine_persistant_services(params)
  end

  # @returns [EnginesOSapiResult]
  # expects a service_hash as @params
  def attach_service(params)
    return success(params[:parent_engine], 'attach service') if @core_api.attach_service(params)
    failed(params[:parent_engine], core_api.last_error, params[:parent_engine])
  end

  # @ retruns [SoftwareServiceDefinition]
  # for type_path [String] and service_provider[String]
  def get_service_definition(type_path, service_provider)
    SoftwareServiceDefinition.find(type_path, service_provider)
  end

  # @ returns [SoftwareServiceDefinition] with TEmplating evaluated
  # requires keys :type_path and 'publisher_namespace :parent_engine
  def get_resolved_service_definition(service_hash)
    @core_api.fillin_template_for_service_def(service_hash)
  end

  # @returns [EnginesOSapiResult]
  # expects a service_hash as @params
  def dettach_service(params)
    return success(params[:parent_engine].to_s, 'detach service') if @core_api.dettach_service(params)
    failed(params[:parent_engine].to_s, core_api.last_error, params[:parent_engine].to_s)
  end

  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to register the service hash with service
  # nothing is written to the service registry
  # effectivitly activating non persistant services
  def register_attached_service(service_query)
    p :register_attached_service
    p service_query
    return success(service_query[:parent_engine].to_s + ' ' + service_query[:service_handle].to_s, 'Register Service') if @core_api.force_register_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'deregister_attached_service failed ')
  end

  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to deregister the service hash from service
  # nothing is written to the service resgitry
  def deregister_attached_service(service_query)   
    p :deregister_attached_service
    p service_query
    return success(service_query[:parent_engine].to_s + ' ' + service_query[:service_handle].to_s, 'Deregister Service') if @core_api.force_deregister_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'deregister_attached_service failed ')
  end

  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to deregister the service hash from service
  # and then to register the service_hash with the service
  # nothing is written to the service resgitry
  def reregister_attached_service(service_query)
    p :reregister_attached_service
    p service_query
    return success(service_query[:parent_engine].to_s + ' ' +service_query[:service_handle].to_s, 'reregister Service') if @core_api.force_reregister_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'reregister_attached_service failed ')
  end

  def get_managed_engine_tree
    @core_api.get_managed_engine_tree
  end

  def get_configurations_tree
    @core_api.get_configurations_tree
  end

  def managed_service_tree
    fetch_managed_service_tree
  end

  def fetch_managed_service_tree
    p :managed_service_tree
    @core_api.managed_service_tree
  end

  def get_orphaned_services_tree
    @core_api.get_orphaned_services_tree
  end

  # @return  an [Array] of service_hashes regsitered against the Service named service name
  # wrapper for gui programs calls get_registered_against_service(params)
  def registered_engines_on_service(service_name)
    r_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'list registered Service') if r_service.nil? || r_service.is_a?(EnginesOSapiResult)
    params = {}
    params[:type_path] = r_service.type_path
    params[:publisher_namespace] = r_service.publisher_namespace
    @core_api.get_registered_against_service(params)
  end

  # @return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    @core_api.get_registered_against_service(params)
  end

  # @return an [Array] of service_hashs of Active persistant services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistant_services(params)
    @core_api.get_active_persistant_services(params)
  end

  # @return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
  # :path_type :publisher_namespace
  def get_orphaned_services(params)
    @core_api.get_orphaned_services(params)
  end

  # @ retruns [SoftwareServiceDefinition]
  # for params :type_path :publisher_namespace
  def software_service_definition(params)
    retval = @core_api.software_service_definition(params)
    return retval if retval.nil? == false
    failed(params[:type_path] + ':' + params[:publisher_namespace], @core_api.last_error, 'get software_service_definition')
  end

  def templated_software_service_definition(params)
    # ret_val = software_service_definition(params)
    @core_api.fillin_template_for_service_def(params)
  end
  #
  #  def list_services_for(object)
  #    return @core_api.list_services_for(object)
  #  end

  # service params and component objectname / and component name and parent name
  def attach_subservice(params)
    return success(params[:service_handle], 'attach subservice') if @core_api.attach_subservice(params)
    SystemUtils.log_error_mesg('attach subservice', params)
    failed(params[:service_handle], @core_api.last_error, 'attach subservice')
  end

  def dettach_subservice(params)
    return success(params[:service_handle], 'attach subservice') if @core_api.dettach_subservice(params)
    SystemUtils.log_error_mesg('attach subservice', params)
    failed(params[:service_handle], @core_api.last_error, 'attach subservice')
  end

  def delete_orphaned_service(params)
    return success(params[:service_handle], 'Delete Service') if @core_api.remove_orphaned_service(params)
    SystemUtils.log_error_mesg('Delete Orphan Service ' + @core_api.last_error.to_s, params)
    failed(params[:service_handle], @core_api.last_error, 'Delete Orphan Service')
  rescue StandardError => e
    log_exception_and_fail('Orphan', e)
  end

  def load_avail_services_for_type(typename)
    @core_api.load_avail_services_for_type(typename)
  end

  def list_attached_services_for(object_name, identifier)
    SystemUtils.debug_output('list_attached_services_for', object_name + ' ' + identifier)
    @core_api.list_attached_services_for(object_name, identifier)
  end

  def startService(service_name)
    s_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Start Service') if s_service.nil?
    return s_service if s_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Start Service') if s_service.start_container
    failed(service_name, s_service.last_error, 'Start Service')
  rescue StandardError => e
    log_exception_and_fail('Start Service', e)
  end

  def pauseService(service_name)
    p_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Pause Service') if p_service.nil?
    return p_service if p_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Pause Service') if p_service.pause_container
    failed(service_name, p_service.last_error, 'Pause Service')
  rescue StandardError => e
    log_exception_and_fail('Pause Service', e)
  end

  def unpauseService(service_name)
    u_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Unpause Service') if u_service.nil?
    return u_service if u_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Unpause Service') if u_service.unpause_container
    failed(service_name, u_service.last_error, 'Unpause Service')
  rescue StandardError => e
    log_exception_and_fail('Unpause Service', e)
  end

  def update_attached_service(params)
    return success(params[:service_handle], 'update attached Service') if @core_api.update_attached_service(params)
    failed(params[:service_handle], @core_api.last_error, 'update_attached_service')
  end

  def update_service_configuration(service_param)
    return success(service_param[:service_name], service_param[:configurator_name]) if @core_api.update_service_configuration(service_param)
    failed(service_param[:service_name], @core_api.last_error, 'update_service_configuration')
  end

  def retrieve_service_configuration(service_param)
    result = @core_api.retrieve_service_configuration(service_param)
    return result if result.is_a?(Hash)
    # FIXME: Gui spats at this failed(service_param[:service_name], @core_api.last_error, 'update_service_configuration')
    return {}
  end

  def stopService(service_name)
    s_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Stop Service') if s_service.nil?
    return s_service if s_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Stop Service') if s_service.stop_container
    failed(service_name, s_service.last_error, 'Stop Service')
  rescue StandardError => e
    log_exception_and_fail('Stop Service', e)
  end

  def set_service_hostname_properties(params)
    success(params[:engine_name], 'update service hostname params')
  rescue StandardError => e
    log_exception_and_fail('set_engine_hostname_details ', e)
  end

  def get_managed_service_details_for(service_function) # WTF
    service = {}
    if service_function == 'http_router'
      service[:provider_namespace] = 'EnginesSystem'
      service[:type_path] = 'nginx'
    end
    service
  end

  def system_status
    return SystemStatus.system_status
  end

  def is_base_system_updating?
    SystemStatus.is_base_system_updating?
  end

  def is_rebooting?
    SystemStatus.is_rebooting?
  end

  def needs_reboot?
    SystemStatus.needs_reboot?
  end

  def engines_system_has_updated
    SystemStatus.engines_system_has_updated?
  end

  def is_engines_system_updating?
    SystemStatus.is_engines_system_updating?
  end

  def is_engines_system_upto_date?
    result = SystemStatus.is_engines_system_upto_date?
    return success('System Up to Date', 'Update Status') if result[:result] == 0
    failed('Updates pending', result[:stdout], 'Update Status')
  end

  def base_system_has_updated?
    SystemStatus.base_system_has_updated?
  end

  def build_status
    SystemStatus.build_status
  end

  def last_build_params
    SystemStatus.last_build_params
  end

  def last_build_failure_params
    SystemStatus.last_build_failure_params
  end

  def current_build_params
    SystemStatus.current_build_params
  end
end
