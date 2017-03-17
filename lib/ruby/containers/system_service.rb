#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'
require 'thread'
require '/opt/engines/lib/ruby/containers/managed_service.rb'

class SystemService < ManagedService
  @ctype = 'system_service'
  def lock_values
    @ctype = 'system_service' if @ctype.nil?
    super
  end

  def certificates
    nil
  end

  def create_service()
    @container_api.create_container(self)
  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :system_service,
      params: params }
  end

  def unpause_container
    @container_api.unpause_container(self)
  end

  def stop_container
    @container_api.stop_container(self)
  end

  def destroy_container
    @container_api.destroy_container(self)
  end

  def start_container
    @container_api.start_container(self)
  end

  def forced_recreate
    SystemDebug.debug(SystemDebug.system,'Forced recreate  System Service ' + container_name)
    begin
      unpause_container
    rescue
    end
    begin
    stop_container
      rescue
      end
    begin
    destroy_container
    rescue
    end
    @container_api.create_container(self)         #start as engine/container or will end up in a loop getting configurations and consumers
  end

  def inspect_container
    SystemDebug.debug(SystemDebug.system,:system_service_inspect_container)

    return false if has_api? == false
    if @docker_info.nil? || @docker_info.is_a?(FalseClass)
      #  @container_api.inspect_container(self)
      @docker_info =  @container_api.inspect_container(self)
      # @docker_info = @last_result
      if @docker_info.is_a?(FalseClass)
        unless has_image?
          SystemUtils.log_output('pulling system service' + container_name.to_s,10)
          pull_image
        end
        SystemUtils.log_output('Creating system service' + container_name.to_s,10)
        @container_api.create_container(self)     
        @docker_info = @last_result
        if @docker_info.is_a?(FalseClass)
          raise EnginesException.new(error_hash('failed to create system service',container_name ))
        end
      end
    end
    # Thread.new { sleep 5 ; @docker_info = nil }
    SystemDebug.debug(SystemDebug.system,:system_service_inspected_container)
    @docker_info
  end

end
