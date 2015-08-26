#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'

#require '/opt/engines/lib/ruby/managed_services/ManagedService.rb'
class SystemService < ManagedService
  
  def  forced_recreate 
    
      unpause_container
      stop_container
      destroy_container
      
      return  @container_api.create_container(self)         #start as engine/container or will end up in a loop getting configurations and consumers  
    end
    
  def inspect_container
    return false  if has_api? == false
   
    if @docker_info == nil || @docker_info == false
      @docker_info = @container_api.inspect_container(self)
      if  @docker_info == false
        if has_image? == false
          SystemUtils.log_output('pulling system service' + container_name.to_s,10)
             pull_image
           end
        SystemUtils.log_output('creating system service' + container_name.to_s,10)
        @container_api.create_container(self)  
        SystemUtils.log_output('created system service' + container_name.to_s,10)
        @docker_info = @container_api.inspect_container(self)
        if @docker_info == false
          p :panic
          exit
        end
      end
    end
    return @docker_info
  end
  
end