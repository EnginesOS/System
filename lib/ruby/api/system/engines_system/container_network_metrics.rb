module ContainerNetworkMetrics
  # FIXME: Kludge should read from network namespace /proc ?
  def get_container_network_metrics(container)
    ret_val = {}
    clear_error

    def error_result
      ret_val = {}
      ret_val[:in] = 'n/a'
      ret_val[:out] = 'n/a'
      return ret_val
    end
    cmd = ['netstat','--interfaces', '-e','|','grep', 'bytes', '|','head', '-1', '|', 'awk', '{ print $2 \" \" $6}']

    result = @engines_core.exec_in_container({:container => container, :command_line => cmd, :log_error => true })
    if result[:result] != 0
      ret_val = error_result
    else
      res = result[:stdout]
      vals = res.split('bytes:')
      if vals.count > 2
        if vals[1].nil? == false && vals[2].nil? == false
          ret_val[:in] = vals[1].chop
          ret_val[:out] = vals[2].chop
        else
          ret_val = error_result
        end
      else
        ret_val = error_result
      end
      ret_val
    end
  end

end