module ContainerSchedules
  def load_schedules(ca)
    ContainerStateFiles.load_schedules(ca)
  end

  def apply_schedules(c)
    schedules = load_schedules(c.store_address)
    # STDERR.puts('SCHEDULES loaded ' + schedules.to_s)
    unless schedules.nil?
      # SystemDebug.debug(SystemDebug.schedules, 'Creating schedules:', schedules)
      schedules.each do |s|
        #  SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:', schedule)
        core.create_and_register_service(cron_service_hash(c, s))
      end
    end
  end

  def remove_schedules(c)
    schedules = load_schedules(c.store_address)
    # STDERR.puts('SCHEDULES loaded ' + schedules.to_s)
    unless schedules.nil?
      # SystemDebug.debug(SystemDebug.schedules, 'Creating schedules:', schedules)
      schedules.each do |s|
        #  SystemDebug.debug(SystemDebug.schedules, 'Creating cro line:', schedule)
        core.dettach_service(cron_service_hash(c, s))
      end
    end
  end

  def cron_service_hash(c, s)
    {
      publisher_namespace: 'EnginesSystem',
      type_path: schedule_type_path(s),
      parent_engine: c.container_name,
      container_type:  c.ctype,
      service_handle: s[:label],
      variables: {
      action_type: schedule_type(s),
      cron_job: schedule_instruction(s),
      title: s[:label],
      :when => cron_line(s[:timespec]),
      parent_engine: c.container_name }
    }
  end

  def container_ctype(ctype)
    ctype = 'engine' if ctype == 'app'
    ctype
  end

  def schedule_type_path(schedule)
    if schedule[:instruction] == 'action'
      'cron'
    else
      'schedule'
    end
  end

  def schedule_type(schedule)
    schedule[:instruction]
    if schedule[:instruction] == 'action'
      schedule[:instruction]
    else
      'schedule'
    end
  end

  def schedule_instruction(schedule)
    unless schedule[:instruction] == "action"
      schedule[:instruction]
    else
      format_actioncron_job(schedule[:actionator])
    end
  end

  def format_actioncron_job(actionator)
    "/home/engines/scripts/actionators/#{actionator[:name]}.sh #{actionator[:params].to_json}"
  end

  def cron_line(timespec)
    #    SystemDebug.debug(SystemDebug.schedules, 'Creating cron  timespec:' , timespec)
    "#{timespec[:minute]} #{timespec[:hour]} #{timespec[:day_of_month]} #{timespec[:month]} #{timespec[:day_of_week]}"
  end

end
