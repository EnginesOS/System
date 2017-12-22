module ManagedContainerServices
  def services 
   @container_api.container_services(self, match)
  end
end