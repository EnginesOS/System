#require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"

#require "/opt/engines/lib/ruby/managed_services/ManagedService.rb"
class SystemService < ManagedService
  
  def  forced_recreate #move elsewhere are this is registry service only
      unpause_container
      stop_container
      destroy_container
      
      return create_container  #start as engine/container or will end up in a loop getting configurations and consumers  
    end
    
  def inspect_container
    return false  if has_api? == false

    if @docker_info == nil || @docker_info == false
      @docker_info = @core_api.inspect_container self
      if  @docker_info == false
        forced_recreate
      end
    end
    return @docker_info
  end
  
end