#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'

#require '/opt/engines/lib/ruby/managed_services/ManagedService.rb'
class SystemService < ManagedService
  @ctype = 'system_service'
  def lock_values
    @ctype = 'system_service' if @ctype.nil?
    super
  end

  def  forced_recreate
    p 'Forced recreate  System Service ' + container_name
    unpause_container
    stop_container
    destroy_container
    return  @container_api.create_container(self)         #start as engine/container or will end up in a loop getting configurations and consumers  
    rescue StandardError => e
      log_exception(e)
  end

  def inspect_container
    return false  if has_api? == false
    if @docker_info.nil? || @docker_info.is_a?(FalseClass)
      @container_api.inspect_container(self)
      @docker_info = @last_result
      if @docker_info.is_a?(FalseClass)
        unless has_image?
          SystemUtils.log_output('pulling system service' + container_name.to_s,10)
          pull_image
        end
        SystemUtils.log_output('creating system service' + container_name.to_s,10)
        return log_error_mesg('Failed to Create System Service',self) if @container_api.create_container(self)
        return log_error_mesg('System Service Failed to start',self) unless @container_api.inspect_container(self)
        @docker_info = @last_result
        if @docker_info.is_a?(FalseClass)
          p :panic
          exit
        end
      end
    end
    Thread.new { sleep 2 ; @docker_info = nil }
    return @docker_info
  end
    rescue StandardError => e
      log_exception(e)
end
