module SystemStatus
  
 
  def first_run_required?
    require_relative '../system/first_run_wizard.rb'
    FirstRunWizard.required?
  end
  def system_status
    require_relative '../system/system_status.rb'
    SystemStatus.system_status
  end 
   
end