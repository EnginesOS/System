module ContainerSchedules
  def load_schedules(container)
      YAML::load(File.read(schedules_file(container)))
  rescue StandardError => e
    puts(' EXCEPTION ' + e.to_s)
  end

  def apply_schedules(container)
    schedules = load_schedules(container)
   # STDERR.puts('SCHEDULES loaded ' + schedules.to_s)
    return true if schedules.nil?
    SystemDebug.debug(SystemDebug.schedules, 'Creating schedules:', schedules)
    schedules.each do |schedule|
      SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:', schedule)
      create_cron_service(container, schedule)
    end
  end

  def create_cron_service(container, schedule)
    t = {
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
    parent_engine: container.container_name } 
    }
    
    STDERR.puts(' CRON SERVIEC HASH ' + t.to_s)
    begin
    @engines_api.create_and_register_service(t)
    rescue StandardError => e
      STDERR.puts('Create Cron service Error ' + e.to_s ) 
      #FIxMe raise exception except when have existing Entry
    end
  end

  def container_ctype(ctype)
    ctype = 'engine' if ctype == 'container'
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