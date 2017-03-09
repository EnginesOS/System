module SubserviceOperations

    def services_subservices(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.services_subservices(params)
    end
  
    def update_subservice(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.update_subservice(params)
    end
  
    def attach_subservice(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.attach_subservice(params)
    end
  
    def remove_subservice(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.remove_subservice(params)
    end
  
    def attached_subservice(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.attached_subservice(params)
    end
  
    def subservice_provided(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.subservice_provided(params)
    end
  
    def subservices_provided(params)
      return r unless  (r = check_sub_service_hash(params))
      service_manager.subservices_provided(params)
    end
    



end