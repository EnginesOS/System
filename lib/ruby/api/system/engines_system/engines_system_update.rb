module EnginesSystemUpdate
  
  def system_update_status
      SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/deb_update_status engines@172.17.42.1 /opt/engines/bin/deb_update_status.sh')
    end
 
 
   def update_engines_system_software
     result = SystemUtils.execute_command('sudo /opt/engines/scripts/_update_engines_system_software.sh ')
     if result[:result] == -1
       @last_error = result[:stderr]
       FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
       return false
     end
     # FIXME: The following carp was added to support gui debug please remove all rails references once gui is sorted
     if Rails.env.production?
     if result[:stdout].include?('Already up-to-date') && File.exist?('/opt/engines/run/system/flags/test_engines_update') == false
       @last_error = result[:stdout]
       FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
       return false
     end
     end
     res = Thread.new { SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@172.17.42.1 /opt/engines/bin/update_engines_system_software.sh') }
     # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
     @last_error = result[:stdout]
     return true if res.status == 'run'
     return false
   end
end