module EnginesSystemUpdate
  def system_update_status
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/deb_update_status engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/deb_update_status.sh')
  end

  def update_engines_system_software
    result = SystemUtils.execute_command('sudo -n /opt/engines/bin/check_engines_system_update_status.sh ')
    SystemDebug.debug(SystemDebug.update,'update_engines_system_software ',  result[:stdout],result[:stderr])
    if result[:result] == -1
      @last_error = 'update_engines_system_software' + result[:stderr]
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      return false  
    end
    if  result[:stdout].start_with?('System Up to Date')
      @last_error = result[:stdout]
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
        return false
    else
      SystemDebug.debug(SystemDebug.update,  result[:stdout],result[:stderr])
    end

    res = Thread.new { result =  SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/update_engines_system_software.sh')
      if result[:result] == -1
      @last_error = result[:stdout].to_s + 'Error:' + result[:stderr].to_s
      else
        @last_error = ''
      end
    }
    
    SystemDebug.debug(SystemDebug.update, :ran, 'ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/update_engines_system_software.sh')
    #Thread.new { SystemUtils.execute_command('/opt/engines/bin/update_engines_system_software.sh')}
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging                                                                                                                      update_engines_system_software.sh
#    @last_error = result[:stdout].to_s + 'Error:' + result[:stderr].to_s
#    return true if result[:result] == 0
#      p result
#    return false
    return true
  end
end