class ManagedUtility< ManagedContainer
  def post_load
    # Basically parent super but no lock on image
    expire_engine_info
    info = @container_api.inspect_container_by_name(self)
    @container_id = info[:Id] if info.is_a?(Hash)
    set_running_user
    domain_name = SystemConfig.internal_domain
    @conf_self_start.freeze
    @container_name.freeze
    @data_uid.freeze
    @data_gid.freeze
    #  @image.freeze This is the one difference
    @repository = '' if @repository.nil?
    @repository.freeze
    @container_mutex = Mutex.new
    @commands = symbolize_keys(@commands)
  end

  def drop_log_dir
    volumes.delete(:log_dir)
  end

  def drop_state_dir
    volumes.delete(:state_dir)
  end

  def on_start
  end

  def  on_create(event_hash)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events,:ON_Create_CALLED,event_hash)
      @container_id = event_hash[:id]
      @out_of_memory = false
      @had_out_memory = false
      save_state
    }
  end

  def command_details(command_name)
    return log_error_mesg('No Commands') unless @commands.is_a?(Hash)
    return @commands[command_name] if @commands.key?(command_name)
    log_error_mesg('Command not found _' + command_name.to_s + '_')
  rescue StandardError => e
    log_exception(e)
  end

  def execute_command(command_name, command_params)
    
   STDERR.puts('FSCONFIGURAT IN ' + read_state.to_s)
   stop_container
    return log_error_mesg('Utility ' + container_name + ' in use ' ,  command_name) if is_active?
    #FIXMe need to check if running
    r =  ''
    #  command_name = command_name.to_sym unless @commands.key?(command_name)
    return log_error_mesg('No such command: ' + command_name.to_s, command_name, command_params) unless @commands.key?(command_name)
    command = command_details(command_name)
    return log_error_mesg('Missing params' + r.to_s, r) if (r = check_params(command, command_params)) == false
    STDERR.puts('FSCONFIGURAT IN ' + read_state.to_s)
    r = destroy_container
   # return r if r.is_a?(EnginesError) #if has_container?
    STDERR.puts('FSCONFIGURAT IN ' + r.to_s)
    @container_api.wait_for('nocontainer') unless read_state == 'nocontainer'
    @container_api.destroy_container(self) unless read_state == 'nocontainer'
    clear_configs
    STDERR.puts('FSCONFIGURAT execute ' + command.to_s + ' With:' + command_params.to_s)
    apply_templates(command, command_params)
    save_state
    create_container()
    STDERR.puts('FSCONFIGURAT IN ' + read_state.to_s)
    start_container
    STDERR.puts('FSCONFIGURAT IN ' + read_state.to_s)
    @container_api.wait_for('stopped') unless read_state == 'stopped'
    r = logs_container #_as_result
    # destroy_container
    {
      stdout: 'OK',
      result: 0
    }
  rescue StandardError => e
    log_exception(e)
  end

  def construct_cmdline(command, command_params, templater)
    command = templater.apply_hash_variables(command, command_params)
    #FixME as will not honor "value with spaces in braces"
    @command = command[:command].split(' ')
  rescue StandardError => e
    log_exception(e)
  end

  def apply_templates(command, command_params)
    templater = Templater.new(@container_api.system_value_access,nil)
    @image = templater.process_templated_string(@image)
    construct_cmdline(command, command_params, templater)
    apply_env_templates(command_params, templater) unless @environments.nil?
    apply_volume_templates(command_params, templater) unless @volumes.nil?
    apply_volume_from_templates(command_params, templater) unless @volumes_from.nil?
  rescue StandardError => e
    log_exception(e)
  end

  def apply_volume_templates(command_params, templater)
    @volumes.each_value do |volume|
    volume = symbolize_keys(volume)
      volume[:remotepath] = templater.apply_hash_variables(volume[:remotepath] , command_params)
      volume[:localpath] = templater.apply_hash_variables(volume[:localpath] , command_params)
      volume[:permissions]= templater.apply_hash_variables(volume[:permissions] , command_params)
    end
  rescue StandardError => e
    log_exception(e)
  end

  def apply_volume_from_templates(command_params  , templater)
    vols = []
    volumes_from.each do |from|
      s = templater.apply_hash_variables(from, command_params)
      vols.push(s) unless s == ""
    end
    @volumes_from = vols
    @volumes_from = nil if vols.size == 0
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
    cmd[:requires].each do |required_param|
      next if params.key?(required_param.to_sym)
      r = 'Missing:' if r == true
      r +=  ' ' + required_param.to_s
    end
    r
  rescue StandardError => e
    #    log_exception(e)
  end

  def container_logs_as_result

  end

  def clear_configs
    FileUtils.rm(ContainerStateFiles.container_state_dir(self) + '/running.yaml') if File.exist?(ContainerStateFiles.container_state_dir(self) + '/running.yaml')
    FileUtils.rm(ContainerStateFiles.container_state_dir(self) + '/running.yaml.bak')   if File.exist?(ContainerStateFiles.container_state_dir(self) + '/running.yaml.bak')
  end

end