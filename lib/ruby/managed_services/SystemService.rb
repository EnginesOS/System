class SystemService < ManagedService
  
  def  forced_recreate #move elsewhere are this is registry service only
      unpause_container
      stop_container
      destroy_container
      
      return create_container  #start as engine/container or will end up in a loop getting configurations and consumers  
    end
    
  
end