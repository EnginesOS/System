module ManagedContainerSchedules
  
  def schedules
    container_api.schedules(store_address)       
  end
  
#  def cron_jobs
#    container_api.cron_jobs(store_address)
#  end
#  
end