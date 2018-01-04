module ManagedContainerServices
  def attached_services(match)
   @container_api.container_services(self, match)
  end
end