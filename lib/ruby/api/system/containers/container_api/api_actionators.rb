module ApiActionators
  @@action_timeout = 20
  def perform_action(c, actionator, params, data = nil)
    SystemDebug.debug(SystemDebug.actions, actionator, params)
    if params.nil? || params.is_a?(String)
      args = params
    else
      args = params.to_json
    end
    
    #  STDERR.puts('/home/actionators/' + actionator_name + '.sh ' + params.to_json + ' .  ' + data.to_s )
    cmds = ['/home/actionators/' + actionator[:name].to_s + '.sh',args.to_s]
    if data.nil?
      result = engines_core.exec_in_container({:container => c, :command_line => cmds, :log_error => true, :data=>nil })
      #      result = SystemUtils.execute_command(cmd)
    else
      result = engines_core.exec_in_container({:container => c, :command_line => cmds, :log_error => true , :data => data})
      #  STDERR.puts('/home/actionators/' + actionator_name + '.sh' + data.to_s)
      # result = SystemUtils.execute_command(cmd, false, data)
    end

    if result[:result] != 0
      raise EnginesException.new(error_hash('Error on performing action ' + c.container_name.to_s + ':' + actionator[:name].to_s , result))
    end
    if result[:stdout].start_with?('{') || result[:stdout].start_with?('"{')
      begin
        return deal_with_json(result[:stdout]) if actionator[:return_type]
      rescue
        return result[:stdout]
      end
    end
    return true if result[:stdout].start_with?('true') || result[:stdout].start_with?('"true')
    result[:stdout]
  end

  def list_params(params)
    return if params.nil?
    r = ' '
    params.each do |param|
      r += param.to_s + ' '
    end
    r
  end

end