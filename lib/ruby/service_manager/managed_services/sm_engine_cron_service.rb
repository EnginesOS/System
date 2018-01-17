module SmEngineCronService
  def retrieve_cron_jobs(container)
    retrieve_engine_service_hashes({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'cron',
      container_type: container.ctype,
      container_name: container.container_name
    })
  end

  def retrieve_cron_entry(cronjob, container)
    retrieve_engine_service_hash({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'cron',
      container_type: container.ctype,
      container_name: container.container_name,
      service_handle: cronjob})[:variables][:cron_job]
  end

end