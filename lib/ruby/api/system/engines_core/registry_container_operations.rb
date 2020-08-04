class EnginesCore
  require_relative '../registry_handler.rb'
  def registry_root_ip
    @registry_handler.registry_root_ip
  end
  def fix_registry_problem
    @registry_handler.fix_problem
  end
  def force_registry_restart
    log_error_mesg("Forcing registry restart ", nil)
    @registry_handler.force_registry_restart
  end

end