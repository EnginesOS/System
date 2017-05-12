module ManagedContainerSchedules
  
  def schedules
    @container_api.schedules(self)       
  end
  
  def cron_jobs
    @container_api.cron_jobs(self)
  end
  
end