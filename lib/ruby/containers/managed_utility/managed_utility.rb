class ManagedUtility< ManagedContainer
 attr_accessor :volumes_from

  def post_load
    
  # Basically parent super but no lock on image 
    expire_engine_info
       set_cont_id
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
    @commands = SystemUtils.symbolize_keys(@commands)
  end

  def on_start
  end

  def on_create
  end

  def command_details(command_name)
    STDERR.puts(@commands.to_s)
    return log_error_mesg('No Commands') unless @commands.is_a?(Hash)
    return @commands[command_name] if @commands.key?(command_name)
    return log_error_mesg('Command not found _' + command_name.to_s + '_')
  rescue StandardError => e

    log_exception(e)
  end

  def execute_command(command_name, command_params)
    
  #FIXMe need to check if running
    r =  '' 
    STDERR.puts("COMMANDS " + @commands.to_s)
    STDERR.puts( ' commaned keys ' + @commands.keys.to_s)
  #  command_name = command_name.to_sym unless @commands.key?(command_name)
    return log_error_mesg('No such command: ' + command_name.to_s, command_name, command_params) unless @commands.key?(command_name)
    command = command_details(command_name)
    return log_error_mesg('Missing params' + r.to_s, r) if (r = check_params(command, command_params)) == false


    destroy_container if has_container?
    @container_api.wait_for('nocontainer') unless read_state == 'nocontainer' 
    clear_configs
    
    apply_templates(command, command_params)
    create_container()
    start_container
    @container_api.wait_for('stopped') unless read_state == 'stopped' 
    r = logs_container #_as_result
   # destroy_container
    STDERR.puts(' logs ' + r.to_s)
    r = {}
    r[:stdout] = 'OK'
    return r

  rescue StandardError => e

    log_exception(e)
  end

  def construct_cmdline(command, command_params, templater)
    command = templater.apply_hash_variables(command, command_params)
    #FixME as will not honor "value with spaces in braces"
    @command = command[:command].split(' ')
    STDERR.puts('COMMAND ' + @command.to_s )
  rescue StandardError => e

    log_exception(e)
  end

  def apply_templates(command, command_params)

    templater = Templater.new(SystemAccess.new,nil)
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
       volume = SystemUtils.symbolize_keys(volume)
    
      STDERR.puts('volume VALUE  ' + volume.to_s )
      volume[:remotepath] = templater.apply_hash_variables(volume[:remotepath] , command_params)
      volume[:localpath] = templater.apply_hash_variables(volume[:localpath] , command_params)
      volume[:permissions]= templater.apply_hash_variables(volume[:permissions] , command_params)
      STDERR.puts('volume VALUE  ' + volume.to_s )
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
      STDERR.puts('ENV VALUE  ' + env.value.to_s )
      env.value = templater.apply_hash_variables(env.value, command_params)
      STDERR.puts('ENV VALUE=  ' + env.value.to_s )
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
      next if params.key?(required_param.to_sym)
      r = 'Missing:' if r == true
      r +=  ' ' + required_param.to_s
    end
    return r
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