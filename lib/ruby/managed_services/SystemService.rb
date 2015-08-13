require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require "/opt/engines/lib/ruby/managed_services/ManagedService.rb"
class SystemService < ManagedService
  
  def  forced_recreate #move elsewhere are this is registry service only
      unpause_container
      stop_container
      destroy_container
      
      return create_container  #start as engine/container or will end up in a loop getting configurations and consumers  
    end
    
  
end