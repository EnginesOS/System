module EnginesServerHost
  
  def system_image_free_space
      result =   run_server_script('free_docker_lib_space')
      return -1 if result[:result] != 0
      return result[:stdout].to_i
    rescue StandardError => e
      log_exception(e)
      return -1
    end
  
    def restart_mgmt
      res = Thread.new { run_server_script('restart_mgmt') }
      # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
      return true if res.status == 'run'
      return false
    end
  
    def api_shutdown(reason)
       log_error_mesg("Shutdown Due to:" + reason.to_s)
      File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
      res = Thread.new { run_server_script('halt_system') }
    end
    
   
    def run_server_script(script_name , script_data=nil)
      
      system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/' + script_name + ' engines@' + SystemStatus.get_management_ip + '  /opt/engines/system/scripts/ssh/' + script_name + '.sh')
      #system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_mgmt engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_mgmt.sh') 
      rescue StandardError => e
           log_exception(e)
           return -1      
    end
    
end