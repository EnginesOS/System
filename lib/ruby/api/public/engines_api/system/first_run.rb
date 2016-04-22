module SystemFirstRun
  def set_first_run_parameters(params_from_gui)
    require_relative '../first_run_wizard.rb'
     params = params_from_gui.dup
     SystemDebug.debug(SystemDebug.first_run,params)
     first_run = FirstRunWizard.new(params)
     first_run.apply(self)
     log_error(first_run.last_error) unless first_run.sucess
     return first_run.sucess
  end
end