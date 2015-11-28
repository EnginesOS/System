module ContainerActions
  def get_container_network_metrics(container_name)
    @core_api.get_container_network_metrics(container_name)
  rescue StandardError => e
    log_exception_and_fail('get_container_network_metrics', e)
  end
  
 def wait_for_container_task(c_type,container_name,timeout=30)
   fn = SystemConfig.RunDir + '/' + c_type + 's/' + container_name + '/task_at_hand'
    return true unless File.exist?(fn)
    loop = 0
    while File.exist?(fn) 
      sleep(0.5)
      loop += 1
       return false if loop > timeout * 2
    end
    return true
 end
 
end