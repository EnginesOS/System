module ManagedContainerSchedules
  
  def schedules
    @container_api.schedule(self)       
  end
end