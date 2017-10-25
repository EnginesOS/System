module BaseOsSystem
  def update_base_os
    res = Thread.new { run_server_script('update_base_os', false, 600) }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    res[:name] = 'update_base_os'
    if res.status == 'run'
      true
    else
      false
    end
  end

  def restart_base_os
    run_server_script('restart_base_os')
    #  system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/system/restart_system engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    # return true if res.status == 'run'
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
    run_server_script('set_locale',  ENV['LANG'].to_s + ' ' + ENV['LANGUAGE'].to_s)
    SystemUtils.execute_command('/opt/engines/system/scripts/ssh/set_locale.sh ' + ENV['LANG'].to_s + ' ' + ENV['LANGUAGE'].to_s, false,  false, nil)
    r = run_server_script('set_locale',  ENV['LANG'].to_s + ' ' + ENV['LANGUAGE'].to_s)
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