module PublicApiSystemFirstRun
  def set_first_run_parameters(params_from_wizard)
    require '/opt/engines/lib/ruby/api/system/first_run_wizard/first_run_wizard.rb'
    params = params_from_wizard.dup
    SystemDebug.debug(SystemDebug.first_run,params)
    first_run = FirstRunWizard.new(params)
    first_run.apply(@core_api)
    return log_error_message(first_run.last_error) unless first_run.sucess
    first_run.sucess
  end

  def first_run_complete(install_mgmt)
    @system_api.first_run_complete(install_mgmt)
  end
end