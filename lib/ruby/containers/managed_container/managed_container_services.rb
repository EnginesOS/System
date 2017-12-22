module ManagedContainerServices
  def services 
   @container_api.engine_services(self, match)
  end
end