module ServiceApiReaders
  def retrieve_reader(container, reader_name)
      cmd = 'docker exec ' +  container.container_name.to_s + ' /home/readers/' + reader_name + '.sh \''       
      result = {}
      begin
        Timeout.timeout(@@configurator_timeout) do
          thr = Thread.new { result = SystemUtils.execute_command(cmd) }
          thr.join
        end
      rescue Timeout::Error
        log_error_mesg('Timeout on running reader',cmd)
        return {}
      end
      @last_error = result[:stderr] # Dont log just set
      return result
    end
    
  def get_readers(container)
    
    service_def = SoftwareServiceDefinition.find(container.type_path, container.publisher_namespace )
              
    return [] unless service_def.key?(:actionators) 
    return [] unless service_def[:actionators].is_a?(Hash)
    return [] unless  service_def[:actionators].key?(:readers)
    return service_def[:actionators][:readers]
           
   end
rescue StandardError => e
  log_exception(e)
  return {}
   
end