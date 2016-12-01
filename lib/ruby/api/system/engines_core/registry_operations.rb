module RegistryOperations
  require_relative '../registry_handler.rb'
  def get_registry_ip
    @registry_handler.get_registry_ip
  end

  def force_registry_restart
    log_error_mesg("Forcing registry restart ", nil)
    @registry_handler.force_registry_restart
  end
  
  def get_registry
    @service_manager.get_registry
  end
end