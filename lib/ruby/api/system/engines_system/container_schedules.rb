module ContainerSchedules
  def schedules(container)
    return nil unless File.exist?(ContainerStateFiles.schedules_file(container))
    YAML::load(File.read(ContainerStateFiles.schedules_file(container) ))
  end

  def apply_schedules(container)
    schedules = schedules(container)
    return true if schedules.nil?
    SystemDebug.debug(SystemDebug.schedules, 'Creating schedules:' , schedules)
    schedules.each do |schedule|
      SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:' , schedule)
      create_cron_service(container, schedule)
    end
  end

  def create_cron_service(container, schedule)
  
    
      t= {
      publisher_namespace: 'EnginesSystem', 
      type_path: 'schedule',
      parent_engine: container.container_name,
      container_type: container.ctype,
      service_handle: schedule[:label],
      variables: { 
        action_type: 'schedule',
        cron_job: schedule_instruction(schedule),
        title: schedule[:label],
        :when => cron_line(schedule[:timespec]),
        parent_engine: container.container_name } }
        SDERR.puts("sche hash " + t.to_s) 
    @engines_api.create_and_register_service(t) 
  end

  def schedule_instruction(schedule)
    return schedule[:instruction] unless  schedule[:instruction] == "action"
    #r = schedule[:actionator]
    schedule[:actionator]

  end

  def cron_line(timespec)
    SystemDebug.debug(SystemDebug.schedules, 'Creating cron  timespec:' , timespec)
    timespec[:minute] + ' ' + timespec[:hour] + ' ' + timespec[:day_of_month] + ' ' + timespec[:month] + ' ' + timespec[:day_of_week]

  end

end