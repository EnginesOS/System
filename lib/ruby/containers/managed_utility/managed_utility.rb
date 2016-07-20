class ManagedUtility< ManagedContainer
  def post_load
    @container_mutex = Mutex.new
  end

  def on_start
  end

  def on_create
  end

  def command_details(command_name)
    STDERR.puts(@commands.to_s)

    return log_error_mesg('No Commands') unless @commands.is_a?(Hash)
    return @commands[command_name.to_s] if @commands.key?(command_name.to_s)
    return log_error_mesg('Command not found _' + command_name.to_s + '_')
  rescue StandardError => e

    log_exception(e)
  end

  def execute_command(command_name, command_params)
    r = ''
    STDERR.puts("COMMANDS " + @commands.to_s)
    STDERR.puts( ' commaned keys ' + @commands.keys.to_s)
  #  command_name = command_name.to_sym unless @commands.key?(command_name)
    return log_error_mesg('No such command: ' + command_name.to_s, command_name, command_params) unless @commands.key?(command_name.to_s)
    command = command_details(command_name)
    return log_error_mesg('Missing params' + r.to_s, r) if (r = check_params(command, command_params)) == false

    apply_templates(command_params)
    create_container()
    start_container
    wait_for('stopped')
    result = container_logs #_as_result
    destroy_container
    return result

  rescue StandardError => e

    log_exception(e)
  end

  def construct_cmdline(command, command_params, templater)
    command = templater.apply_hash_variables(command, command_params)
    #FixME as will not honor "value with spaces in braces"
    @command = command.split(' ')

  rescue StandardError => e

    log_exception(e)
  end

  def apply_templates(command_params)

    templater = Templater.new(SystemAccess.new,nil)

    construct_cmdline(command, command_params, templater)

    apply_env_templates(command_params, templater) unless @environments.nil?

    apply_volume_templates(command_params, templater) unless @volumes.nil?

    apply_volume_from_templates(command_params, templater) unless @volumes_from.nil?

  rescue StandardError => e

    log_exception(e)
  end

  def apply_volume_templates(command_params, templater)
    @volumes.each_value do |volume|
      volume[:remotepath] = templater.apply_hash_variables(volume[:remotepath] , command_params)
      volume[:localpath] = templater.apply_hash_variables(volume[:localpath] , command_params)
      volume[:permissions] = templater.apply_hash_variables(volume[:permissions] , command_params)
    end
  rescue StandardError => e

    log_exception(e)
  end

  def apply_volume_from_templates(command_params, templater)
    volumes_from.each_value do |from|
      from[:volume_from] = templater.apply_hash_variables(from[:volume_from], command_params)
    end
  rescue StandardError => e

    log_exception(e)
  end

  def apply_env_templates(command_params, templater)
    environments.each do |env|
      env.value = templater.apply_hash_variables(env.value, command_params)
    end
  rescue StandardError => e

    log_exception(e)
  end

  def resolved_strings(text, values_hash,templater)

    env_value = templater.apply_hash_variables(text, values_hash)
    return env_value
  rescue StandardError => e

    log_exception(e)
  end

  def check_params(cmd, parrams)
    r = true
    STDERR.puts(' required params' ,params.to_s)
    cmd[:requires].each do |required_param|
      STDERR.puts(' required param ' + required_param.to_s )
      next if params.key?(required_param.to_s)
      r = 'Missing:' if r == true
      r +=  ' ' + required_param.to_s
    end
    return r
  rescue StandardError => e

    #    log_exception(e)
  end

  def container_logs_as_result

  end

end