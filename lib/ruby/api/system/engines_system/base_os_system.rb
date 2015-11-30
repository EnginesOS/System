module BaseOsSystem
  def update_system
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_system engines@' + SystemStatus.get_management_ip + ' /opt/engines/bin/update_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
  end

  def restart_system
    GC.start
    ObjectSpace.dump(@system_api,output: File.open('var/log/apache2/system.json','w'))
    ObjectSpace.dump(self, output: File.open('/var/log/apache2/engines.json','w'))
    ObjectSpace.dump_all(output: File.open('/var/log/apache2/heap.json','w'))
    ObjectSpace.dump(@registry_handler,output: File.open('/var/log/apache2/registry_handler.json','w'))
    ObjectSpace.dump(@container_api,output: File.open('/var/log/apache2/container_api.json','w'))
    ObjectSpace.dump(@service_api,output: File.open('/var/log/apache2/service_api.json','w'))
    ObjectSpace.dump(@docker_api,output: File.open('/var/log/apache2/docker_api.json','w'))
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_system engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
    return false
  end

end