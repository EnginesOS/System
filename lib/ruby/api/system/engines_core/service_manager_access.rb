def service_manager
  @service_manager = ServiceManager.new(self) unless @service_manager.is_a?(ServiceManager)
  return @service_manager
end

