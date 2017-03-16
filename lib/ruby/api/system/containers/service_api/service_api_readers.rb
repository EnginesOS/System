module ServiceApiReaders
  def retrieve_reader(container, reader_name)
    cmd = '/home/readers/' + reader_name + '.sh'
    result = {}
    begin
      Timeout.timeout(@@configurator_timeout) do
        thr = Thread.new { result =  @engines_core.exec_in_container({:container => c, :command_line => [cmd], :log_error => true }) }
        thr.join
      end
    rescue Timeout::Error
    raise EnginesException.new(error_hash('Timeout on running reader', cmd))
    end
    @last_error = result[:stderr] # Dont log just set
     result
  end

  def get_readers(container)

    service_def = SoftwareServiceDefinition.find(container.type_path, container.publisher_namespace )

    return [] unless service_def.key?(:actionators)
    return [] unless service_def[:actionators].is_a?(Hash)
    return [] unless  service_def[:actionators].key?(:readers)
     service_def[:actionators][:readers]

  end
rescue StandardError => e
   log_exception(e)

end