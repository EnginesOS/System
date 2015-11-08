module Subservices
 
  def all_subservices_registered_to(service_type)
    test_subservices_result(@subservices_registry.all_subservices_registered_to(service_type))
  end
  
  def find_subservice_consumers(params)
    test_subservices_result(@subservices_registry.find_engine_services_hashes(params))
  end
  
  def get_subservices_registered_against_service(params)
    test_subservices_result(@subservices_registry.find_engine_services_hashes(params))
  end
  
  def get_subservice_entry(params)
    test_subservices_result(@subservices_registry.get_subservice_entry(params))
  end
  
  def subservice_is_registered?(params)
    test_subservices_result(@subservices_registry.subservice_is_registered?(params))
  end
  
  def add_to_subservices_registry(params)
    test_subservices_result(@subservices_registry.add_to_subservices_registry(params))
  end
  
  def update_attached_subservice(params)
    test_subservices_result(@subservices_registry.update_attached_subservice(params))
  end
  
  def remove_from_subservices_registry()
    test_subservices_result(@subservices_registry.remove_from_subservices_registry())
  end
  
end