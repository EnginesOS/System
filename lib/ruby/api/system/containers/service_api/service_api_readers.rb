module ServiceApiReaders
  def retrieve_reader(c, reader_name)
    cmd = "/home/readers/#{reader_name}.sh"
    result = ''
    begin

      thr = Thread.new { result =  core.exec_in_container({:container => c, :command_line => [cmd], :log_error => true}) }
      thr[:name] = "action reader #{c.container_name}"
      #  STDERR.puts('Thread ' +  thr.inspect)
      Timeout.timeout(@@configurator_timeout) do
        thr.join
      end
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Timeout on running reader', cmd))
    rescue StandardError => e
      SystemUtils.log_exception(e , 'retrieve_reader:' + cmd)
      thr.exit unless thr.nil?
    end
    raise EnginesException.new(error_hash('Invalid Reader Result', result)) unless result.is_a?(Hash)
    @last_error = result[:stderr] # Dont log just set
    result
  end

  def get_readers(container)
    r = nil
    service_def = SoftwareServiceDefinition.find(container.type_path, container.publisher_namespace )
    if service_def.key?(:actionators)
      if service_def[:actionators].is_a?(Hash)
        if service_def[:actionators].key?(:readers)
          r = service_def[:actionators][:readers]
        end
      end
    end
    r
  end

end
