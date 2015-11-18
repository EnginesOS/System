module EnginesSystemInfo
  def system_status
    return SystemStatus.system_status
  end
  def first_run_required?
     FirstRunWizard.required?
   end
  def  is_remote_exception_logging?
    SystemStatus.is_remote_exception_logging?
   end
  def get_engines_system_release
    SystemStatus.get_engines_system_release
  end
    def build_status
      SystemStatus.build_status
    end
 
end