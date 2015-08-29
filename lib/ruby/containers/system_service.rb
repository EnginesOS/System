#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'

#require '/opt/engines/lib/ruby/managed_services/ManagedService.rb'
class SystemService < ManagedService
  @ctype = 'system_service'
  
  def lock_values      
    @ctype = 'system_service' if @ctype.nil?
         super.lock_values
       end
  end       
  
  def  forced_recreate 
      #log_error_mesg('Forced recreate  resgitroy',nil)
    p 'Forced recreate  resgitroy'
      unpause_container
      stop_container
      destroy_container
      
      return  @container_api.create_container(self)         #start as engine/container or will end up in a loop getting configurations and consumers  
    end
    
  def inspect_container
    return false  if has_api? == false
   
    if @docker_info == nil || @docker_info == false
      @container_api.inspect_container(self)
      @docker_info = @last_result
      if  @docker_info == false
       unless has_image?
          SystemUtils.log_output('pulling system service' + container_name.to_s,10)
             pull_image
           end
        SystemUtils.log_output('creating system service' + container_name.to_s,10)
        @container_api.create_container(self)  
        SystemUtils.log_output('created system service' + container_name.to_s,10)
        return false unless @container_api.inspect_container(self)
        @docker_info = @last_result  
        if @docker_info == false
          p :panic
          exit
        end
      end
    end
    Thread.new { sleep 3 ; @docker_info = nil }    
    return @docker_info
  end
  
end