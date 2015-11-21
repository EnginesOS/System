module EngineStatusFlags
  
  def restart_required?(container)
      return File.exist?(ContainerStateFiles.restart_flag_file(container))
  
    end
    
  
    def rebuild_required?(container)
      return File.exist?(ContainerStateFiles.rebuild_flag_file(container))
    end
  
    def restart_reason(container)
      return false unless File.exist?(ContainerStateFiles.restart_flag_file(container))
      return File.read(ContainerStateFiles.restart_flag_file(container))
  
    end
  
    def rebuild_reason(container)
      return false unless File.exist?(ContainerStateFiles.rebuild_flag_file(container))
      return File.read(ContainerStateFiles.restart_flag_file(container))
    end

  def is_startup_complete(container)
     clear_error
     return test_system_api_result(@system_api.is_startup_complete(container))
   rescue StandardError => e
     log_exception(e)
   end
   
   
end