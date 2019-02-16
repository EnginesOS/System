module ApiActionators
  #   @@action_timeout = 20
  def perform_action(c, actionator, params, data = nil)
    SystemDebug.debug(SystemDebug.actions, actionator, params)
    if params.nil?
      stream = nil
    elsif params.key?(:stream)
      stream = params[:stream]
      params.delete(:stream)
    else
      stream = nil
    end

    cmds = ['/home/engines/scripts/actionators/' + actionator[:name].to_s + '.sh']
    req =
    {container: c,
      command_line: cmds,
      log_error:  true,
      data_stream: stream}

    if  params.is_a?(Hash)
      req[:action_params] = params
    elsif data.nil?
      data = params
    end

    result = engines_core.exec_in_container(req)

    if result[:result] == 0
      if result[:stdout].start_with?('{') || result[:stdout].start_with?('"{')
        begin
          deal_with_json(result[:stdout]) if actionator[:return_type]
        rescue
          result[:stdout]
        end
      elsif result[:stdout].start_with?('true') || result[:stdout].start_with?('"true')
        true
      else
        result[:stdout]
      end
    else
      raise EnginesException.new(warning_hash('Error on performing action ' + c.container_name.to_s + ':' + actionator[:name].to_s , result)) if result[:result] == 1
      raise EnginesException.new(error_hash('Error on performing action ' + c.container_name.to_s + ':' + actionator[:name].to_s , result))
    end
  end

  def list_params(params)
    unless params.nil?
      r = ' '
      params.each do |param|
        r += param.to_s + ' '
      end
      r
    end
  end

end