module Service_ApiReaders
  def retrieve_reader(container, reader_name)
      cmd = 'docker exec ' +  container.container_name.to_s + ' /home/readers/' + reader_name + '.sh \''       
      result = {}
      begin
        Timeout.timeout(@@configurator_timeout) do
          thr = Thread.new { result = SystemUtils.execute_command(cmd) }
          thr.join
        end
      rescue Timeout::Error
        log_error_mesg('Timeout on running configurator',cmd)
        return {}
      end
      @last_error = result[:stderr] # Dont log just set
      return result
    end
end