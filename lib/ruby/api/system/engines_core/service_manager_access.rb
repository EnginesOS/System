def create_service_manager
  @service_manager = ServiceManager.new(self) unless @service_manager.is_a?(ServiceManager)
   @service_manager
end


