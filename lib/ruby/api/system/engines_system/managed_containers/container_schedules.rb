module ContainerSchedules
  def schedules(container)
    STDERR.puts('SCHEDULES FILE ' + schedules_file(container).to_s)
    return nil unless File.exist?(schedules_file(container))
    c = File.read(schedules_file(container))    
    STDERR.puts('SCHEDULES ' + c.to_s)
    d = YAML::load(c)
    STDERR.puts('SCHEDULES ' + d.to_s)
    d
  rescue StandardError => e
    puts('EXCEPTION ' + e.to_s)
  end

  def apply_schedules(container)
    STDERR.puts(' SCHEDULES ' + container.container_name)
    schedules = schedules(container)
    STDERR.puts(' SCHEDULES ' + schedules.to_s)
    return true if schedules.nil?
    SystemDebug.debug(SystemDebug.schedules, 'Creating schedules:', schedules)
    schedules.each do |schedule|
      SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:', schedule)
      create_cron_service(container, schedule)
    end
  end

  def create_cron_service(container, schedule)
    @engines_api.create_and_register_service({
      publisher_namespace: 'EnginesSystem',
      type_path: schedule_type_path(schedule),
      parent_engine: container.container_name,
      container_type: container_ctype(container.ctype),
      service_handle: schedule[:label],
      variables: {
      action_type: schedule_type(schedule),
      cron_job: schedule_instruction(schedule),
      title: schedule[:label],
      :when => cron_line(schedule[:timespec]),
      parent_engine: container.container_name } })
  end

  def container_ctype(ctype)
    return 'engine' if ctype == 'container'
    ctype
  end

  def schedule_type_path(schedule)
    return 'schedule' unless schedule[:instruction] == 'action'
    'cron'
  end

  def schedule_type(schedule)
    return 'schedule' unless schedule[:instruction] == 'action'
    schedule[:instruction]
  end

  def schedule_instruction(schedule)
    return schedule[:instruction] unless schedule[:instruction] == "action"
    format_actioncron_job(schedule[:actionator])
  end

  def format_actioncron_job(actionator)
    '/home/actionators/' + actionator[:name] + '.sh ' + actionator[:params].to_json.to_s
  end

  def cron_line(timespec)
    SystemDebug.debug(SystemDebug.schedules, 'Creating cron  timespec:' , timespec)
    timespec[:minute] + ' ' + timespec[:hour] + ' ' + timespec[:day_of_month] + ' ' + timespec[:month] + ' ' + timespec[:day_of_week]
  end

end