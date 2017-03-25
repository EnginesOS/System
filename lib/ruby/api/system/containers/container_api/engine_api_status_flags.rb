module EngineApiStatusFlags
  def restart_required?(container)
    File.exist?(@system_api.restart_flag_file(container))
  end

  def rebuild_required?(container)
    File.exist?(@system_api.rebuild_flag_file(container))
  end

  def restart_reason(container)
    return false unless File.exist?(@system_api.restart_flag_file(container))
    File.read(@system_api.restart_flag_file(container))
  end

  def rebuild_reason(container)
    return false unless File.exist?(@system_api.rebuild_flag_file(container))
    File.read(@system_api.restart_flag_file(container))
  end

  def is_startup_complete(container)
    clear_error
    @system_api.is_startup_complete(container)
  end

end