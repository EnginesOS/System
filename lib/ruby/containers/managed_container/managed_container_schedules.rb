module ManagedContainerSchedules
  
  def schedules
    container_api.schedules(store_address)       
  end

end