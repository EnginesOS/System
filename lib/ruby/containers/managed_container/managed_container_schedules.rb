module ManagedContainerSchedules
  
  def schedules
    @container_api.schedules(self)       
  end
end