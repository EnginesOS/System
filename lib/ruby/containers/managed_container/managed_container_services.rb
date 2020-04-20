module ManagedContainerServices
  def attached_services(match)
   container_api.container_services(store_address, match)
  end
end