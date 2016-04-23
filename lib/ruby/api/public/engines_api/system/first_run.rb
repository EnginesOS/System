module PublicApiSystemFirstRun
  def set_first_run_parameters(params_from_gui)
    require '/opt/engines/lib/ruby/api/system/first_run_wizard.rb'
    params = params_from_gui.dup
     SystemDebug.debug(SystemDebug.first_run,params)
     first_run = FirstRunWizard.new(params)
     first_run.apply(@core_api)
     return false unless first_run.sucess
     return first_run.sucess
  end
end