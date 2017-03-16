module PublicApiStatus
  def first_run_required?
    require '/opt/engines/lib/ruby/api/system/first_run_wizard/first_run_wizard.rb'
    FirstRunWizard.required?
  rescue StandardError => e
    handle_exception(e)
  end

  def system_status
    require '/opt/engines/lib/ruby/api/system/system_status.rb'
    SystemStatus.system_status
  rescue StandardError => e
    handle_exception(e)
  end

end