module PublicApiContainersPersistentServices
 
    
   def list_persistent_services(engine)
     @service_manager.list_persistent_services(engine)
   end
end