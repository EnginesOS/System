require_relative 'network_system_registry.rb'

class SystemRegistry
  attr_accessor  :last_error
  
  def initialize(core_api)
    @network_registry = NetworkSystemRegistry.new( core_api)
  end

  def test_result(request_result_hash)
   clear_error
    if request_result_hash == nil ||  request_result_hash == false
      @last_error = @network_registry.last_error      
        return request_result_hash
    end
    if request_result_hash[:result]=='OK'
      p request_result_hash[:object].class.name
      return request_result_hash[:object]
    end
    @last_error = request_result_hash[:error].to_s + ':'+@network_registry.last_error.to_s
      if   request_result_hash.has_key?(:object)     
        return request_result_hash[:object]     
      end
      return nil   
  end
#  
#  def  find_engine_services(params)
#    test_result(send_request('find_engine_services',params))
#  end
  def  remove_from_managed_engines_registry(params)
    test_result(send_request('remove_from_managed_engines_registry',params))
  end
  
  def find_engine_service_hash(params)
    test_result(send_request('find_engine_service_hash',params))
    end
    
  def  find_engine_services_hashes(params)
    test_result(send_request('find_engine_services_hashes',params))
  end
  def  find_engine_service_hash(params)
      test_result(send_request('find_engine_service_hash',params))
    end
  def get_engine_nonpersistant_services(params)
    test_result(send_request('get_engine_nonpersistant_services',params))
  end

  def get_engine_persistant_services(params)
    test_result(send_request('get_engine_persistant_services',params))
  end

  def remove_from_managed_engines_registry(service_hash)
    test_result(send_request('remove_from_managed_engines_registry',service_hash))
  end

  def add_to_managed_engines_registry(service_hash)
    test_result(send_request('add_to_managed_engines_registry',service_hash))
  end

  #
  def save_as_orphan(params)
    p :save_as_orphan
    p params
    test_result(send_request('save_as_orphan',params))
  end

  def release_orphan(params)
    p :release_orphan
    p params
    test_result(send_request('release_orphan',params))
  end

  #
  def reparent_orphan(params)
    p :reparent_orphan
    p params
    test_result(send_request('reparent_orphan',params))
  end
  def rebirth_orphan(params)
    p :reparent_orphan
    p params
    test_result(send_request('rebirth_orphan',params))
  end
  #
  def retrieve_orphan(params)
    p :retrieve_orphan
    p params
    test_result(send_request('retrieve_orphan',params))
  end

  #
  def get_orphaned_services(params)
    p :get_orphaned_services
    p params
    test_result(send_request('get_orphaned_services',params))
  end

  #
  def find_orphan_consumers(params)
    p :get_orphaned_services
    p params
    test_result(send_request('find_orphan_consumers',params))
  end

  #
  def orphanate_service(service_query_hash)
    p :get_orphaned_services
    p service_query_hash
    test_result(send_request('orphanate_service',service_query_hash))
  end

  #
  #
  def  find_service_consumers(service_query_hash)
    test_result(send_request('find_service_consumers',service_query_hash))
  end

  #
  def  update_attached_service(service_hash)
    test_result(send_request('update_attached_service',service_hash))
  end

  #
  def  add_to_services_registry(service_hash)
    test_result(send_request('add_to_services_registry',service_hash))
  end

  #
  def  remove_from_services_registry(service_hash)
    test_result( send_request('remove_from_services_registry',service_hash))
  end

  #
  def  service_is_registered?(service_hash)
    test_result( send_request('service_is_registered?',service_hash))
  end

  #
  def  get_registered_against_service(params)
    test_result(send_request('get_registered_against_service',params))
  end


  def  get_service_entry(service_hash)
     test_result( send_request('get_service_entry',service_hash))
   end
  #
  def  get_service_configurations_hashes(service_hash)
    test_result( send_request('get_service_configurations_hashes',service_hash))
  end

  #
  def  update_service_configuration(config_hash)
    test_result(send_request('update_service_configuration',config_hash))
  end

  #@return an Array of Strings of the Provider names in use
  #returns nil on failure
  
  def  list_providers_in_use
    res = send_request('list_providers_in_use',nil)
    p res.to_s
    test_result(send_request('list_providers_in_use',nil))
  end

  #
  #@ Return complete system registry tree 
  def  system_registry_tree
    test_result(send_request('system_registry_tree',nil))
  end

  #
  def  service_configurations_registry
    test_result(send_request('service_configurations_registry',nil))
  end

  #
  def  orphaned_services_registry
    test_result(send_request('orphaned_services_registry',nil))
  end

  #
  def  services_registry
    test_result(send_request('services_registry',nil))
  end

  #
  def  managed_engines_registry
    test_result(send_request('managed_engines_registry',nil))
  end

  def clear_error
    @last_error = ''
  end
  
  private

  def send_request(command,params)
    request_result = @network_registry.send_request(command,params)
    @last_error = @network_registry.last_error
    return request_result
  end
end