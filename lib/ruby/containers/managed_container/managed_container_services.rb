module ManagedContainerServices
  def attached_services(match)
   container_dock.container_services(store_address, match)
  end
end