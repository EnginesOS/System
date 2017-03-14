module BaseOsSystem
  def update_base_os
    res = Thread.new { run_server_script('update_base_os') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
  end

  def restart_base_os    
    run_server_script('restart_base_os')
  #  system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_system engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
   # return true if res.status == 'run'
     true
  end
end