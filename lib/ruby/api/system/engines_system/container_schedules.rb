module ContainerSchedules
  def schedules(container)
    return nil unless File.exist?(ContainerStateFiles.schedules_file(container))
    YAML::load(File.read(ContainerStateFiles.schedules_file(container) ))
  end

  def apply_schedules(container)
    schedules = schedules(container)
    return true if schedules.nil?

    schedules.each do |schedule|
      create_cron_service(container, schedule)
    end
  end

  def create_cron_service(container, schedule)
    SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:' , schedule)
    @engines_api.create_and_register_service( {publisher_namespace: 'EnginesSystem', type_path: 'cron',
      variables: { action_type: 'schedule',
      cron_job: schedule_instruction(schedule[:timespec]),
      title: schedule[:lable],
      :when => cron_line(schedule),
      parent_engine: container.container_name } }   )
  end

  def schedule_instruction(schedule)
    return schedule[:action] unless  schedule[:action] == "action"
    #r = schedule[:actionator]
    schedule[:actionator]

  end

  def cron_line(timespec)
    SystemDebug.debug(SystemDebug.schedules, 'Creating cron  timespec:' , schedule)
    timespec[:minute] + ' ' + timespec[:hour] + ' ' + timespec[:day_of_month] + ' ' + timespec[:month] + ' ' + timespec[:day_of_week]

  end

end