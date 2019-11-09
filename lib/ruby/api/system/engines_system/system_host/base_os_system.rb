module BaseOsSystem
  def update_base_os
    event_handler.trigger_system_update_event('OS updating')
    res = Thread.new { run_server_script('update_base_os', false, 600) }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    res[:name] = 'update_base_os'
    if res.status == 'run'
      true
    else
      event_handler.trigger_system_update_event('failed')
      raise EnginesException.new(error_hash('Failed to update os ', res))
    end
  rescue StandardError => e
    SystemUtils.log_exception(e , 'update_base_os:')
    event_handler.trigger_system_update_event('failed')
    res.exit unless res.nil?
  end

  def restart_base_os
    event_handler.trigger_engines_restart_event('OS restarting')
    run_server_script('restart_base_os')
    true
  end

  # :country_code , :lang_code
  def set_locale(locale)
    prefs = SystemPreferences.new
    prefs.set_country_code(locale[:country_code])
    prefs.set_langauge_code(locale[:lang_code])
    ENV['LANG'] = locale[:lang_code].to_s + '_' + locale[:country_code].to_s  + '.UTF-8'
    ENV['LC_ALL'] = locale[:lang_code].to_s + '_' + locale[:country_code].to_s  + '.UTF-8'
    ENV['LANGUAGE'] = locale[:country_code].to_s  + ':' + locale[:lang_code].to_s
    run_server_script('set_locale',  "#{ENV['LANG']} #{ENV['LANGUAGE']}")
    SystemUtils.execute_command("/opt/engines/system/scripts/ssh/set_locale.sh  #{ENV['LANG']} #{ENV['LANGUAGE']}", false,  false, nil)
    r = run_server_script('set_locale',   "#{ENV['LANG']} #{ENV['LANGUAGE']}")
    if r[:result] == 0
      true
    else
      r
    end
  end

  def set_timezone(tz)
    ENV['TZ'] = tz
    r = run_server_script('set_timezone', tz)
    if r[:stderr] == ''
      true
    else
      r
    end
  end

  def get_locale
    locale_str = ENV["LANG"]
    # STDERR.puts('LANG '  + locale_str.to_s)
    if locale_str.nil?
      nil
    else
      bit = locale_str.split('.')
      bits = bit[0].split('_')
      {
        lang_code: bits[0],
        country_code: bits[1]
      }
    end
  end

  def get_timezone
    r = run_server_script('get_timezone')
    if r[:result] == 0
      r[:stdout].strip
    else
      r
    end
  end

end