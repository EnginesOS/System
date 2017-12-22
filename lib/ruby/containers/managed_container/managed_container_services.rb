module ManagedContainerServices
  def attached_services 
   @container_api.container_services(self, match)
  end
end