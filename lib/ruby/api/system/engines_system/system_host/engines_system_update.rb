module EnginesSystemUpdate
  def system_update_status
    run_server_script('deb_update_status')
  end

  def update_engines_system_software
    result = run_server_script('check_engines_system_update_status')
    SystemDebug.debug(SystemDebug.update, 'update_engines_system_software ', result[:stdout], result[:stderr])
    if result[:result] == -1
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      raise EnginesException.new(error_hash('update_engines_system_software' + result[:stderr]))
    end
    if result[:stdout].start_with?('System Up to Date')
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      raise EnginesException.new(warning_hash('Engines is already up to date'))
    else
      SystemDebug.debug(SystemDebug.update,  result[:stdout],result[:stderr])
    thr = Thread.new { result = run_server_script('update_engines_system_software')
      thr[:name] = 'update_engines_system_software'
      raise EnginesException.new(error_hash(result[:stdout].to_s + 'Error:' + result[:stderr].to_s)) if result[:result] == -1
    }
    true
  end
  end
end