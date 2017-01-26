module ApiActionators
  @@action_timeout = 20
  def perform_action(c,actionator_name, params, data=nil)
    if params.nil? || params.is_a?(String)
      args = params
    else
      args = params.to_json
    end

    cmds = ['/home/actionators/' + actionator_name + '.sh',args.to_s]
            if data.nil?
              result = engines_core.exec_in_container({:container => c, :command_line => cmds, :log_error => true, :data=>nil })
              #      result = SystemUtils.execute_command(cmd)
            else
              result = engines_core.exec_in_container({:container => c, :command_line => cmds, :log_error => true , :data => data})
              # result = SystemUtils.execute_command(cmd, false, data)
            end
          
    return result if result.is_a?(EnginesError)

    if result[:result] == 0
      if result[:stdout].start_with?('{') || result[:stdout].start_with?('"{')
        begin
          return SystemUtils.deal_with_jason(JSON.parse( result[:stdout], :create_additons => true ))
        rescue
          return result[:stdout]
        end
      end
      return true if result[:stdout].start_with?('true') || result[:stdout].start_with?('"true')
      return result[:stdout]
    end
    return log_error_mesg('Error on performing action ' + c.container_name.to_s + ':' + actionator_name.to_s + result[:stderr] ,result)
  rescue StandardError =>e
    log_exception(e)

  end

  def list_params(params)
    return ' ' if params.nil?
    r = ' '
    params.each do |param|
      r += param.to_s + ' '
    end
    return r
  end

end