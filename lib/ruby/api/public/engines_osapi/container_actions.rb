module ContainerActions
  def get_container_network_metrics(container_name)
    @core_api.get_container_network_metrics(container_name)
  rescue StandardError => e
    log_exception_and_fail('get_container_network_metrics', e)
  end
  
 def wait_for_container_task(ctype,container_name,timeout=30)
   if ctype == 'container'
     c = loadManagedEngine(container_name)
   else
      c = getManagedService(container_name)
   end
  return c.wait_for_container_task(timeout) unless c.nil?
  return false
   
 end
 
end