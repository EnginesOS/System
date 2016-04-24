module PublicApiContainersNonPersistentServices
 def force_register_attached_service(service_hash)
   @service_manager.register_non_persistent_service(service_hash)
 end
 def force_reregister_attached_service(service_hash)
   service_manager.force_reregister_attached_service(service_hash)
 end
 def force_deregister_attached_service(service_hash)
   @service_manager.deregister_non_persistent_service(service_hash)
 end
    
   def list_non_persistent_services(engine)
     @service_manager.list_non_persistent_services(engine)
   end
end