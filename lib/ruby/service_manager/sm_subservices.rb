module SMSubservices
 
  def services_subservices(params)
    test_subservices_result(@subservices_registry.services_subservices(params))
     end
   
     def update_subservice(params)
       test_subservices_result(@subservices_registry.update_subservice(params))
     end
   
     def attach_subservice(params)
       test_subservices_result(@subservices_registry.attach_subservice(params))
     end
   
     def remove_subservice(params)
       test_subservices_result(@subservices_registry.remove_subservice(params))
     end
   
     def attached_subservice(params)
       test_subservices_result(@subservices_registry.attached_subservice(params))
     end
   
     def subservice_provided(params)
       test_subservices_result(@subservices_registry.subservice_provided(params))
     end
   
     def subservices_provided(params)
       test_subservices_result(@subservices_registry.subservices_provided(params))
     end
 
  
end