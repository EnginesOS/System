def create_service_manager
  @service_manager = ServiceManager.new(self) unless @service_manager.is_a?(ServiceManager)
  return @service_manager
end


def service_manager
  return create_service_manager if @service_manager.nil?
  return  @service_manager
  
end
