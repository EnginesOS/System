class ManagedUtility< ManagedContainer
  require_relative 'managed_utility_on_action.rb'
  include ManagedUtilityOnAction
  def post_load
    # Basically parent super but no lock on image
    expire_engine_info
    begin
      info = @container_api.inspect_container_by_name(self)
      @container_id = info[:Id] if info.is_a?(Hash)
    rescue
    end
    set_running_user
    @domain_name = SystemConfig.internal_domain
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

  def command_details(command_name)
    raise EnginesException.new(error_hash('No Commands', command_name)) unless @commands.is_a?(Hash)
    if @commands.key?(command_name)
      @commands[command_name]
    else
      raise EnginesException.new(error_hash('Command not found _', command_name.to_s ))
    end
  end

  def execute_command(command_name, command_params)
    STDERR.puts("\n EXECutre Cmd " + command.to_s + ':' + command_params.to_s)
    if is_active?
      expire_engine_info     
      wait_for('stop', 60)
      raise EnginesException.new(error_hash('Utility ' + container_name + ' in use ', command_name)) if is_active?
      destroy_container
    end

    r =  ''
    #  command_name = command_name.to_sym unless @commands.key?(command_name)
    raise EnginesException.new(error_hash('No such command: ' + command_name.to_s + ' in ' + @commands.to_s,  command_params)) unless @commands.key?(command_name)
    command = command_details(command_name)
    raise EnginesException.new(error_hash('Missing params in Exe' + command_params.to_s, r)) unless (r = check_params(command, command_params)) == true
    begin
      destroy_container
    rescue
    end
    wait_for('nocontainer') if has_container?
    begin
      @container_api.destroy_container(self) if has_container?
      wait_for('nocontainer')
    rescue
    end
    raise EnginesException.new(error_hash('cant nocontainer Utility ' + command.to_s, command_params.to_s)) if has_container?
    clear_configs
    apply_templates(command, command_params)
    save_state
       STDERR.puts('Create FSCONFIG')
    create_container()
   
#    wait_for('stopped',120) unless is_stopped?
#    begin
#      r = @container_api.logs_container(self, 512) #_as_result
#      STDERR.puts('UIL RESULT:' + r.to_s)
#      if r.is_a?(Hash)
#        r
#      else
#        {stdout: r.to_s, result: 0}
#      end
#    rescue StandardError => e
#      STDERR.puts(e.to_s  + "\n" + e.backtrace.to_s)
#      STDERR.puts('FSCONFIG EXCEPTION' + e.to_s)
#      {stderr: 'Failed', result: -1}
#    end
  end

  def construct_cmdline(command, command_params, templater)
    command = templater.apply_hash_variables(command, command_params)
    #FixME as will not honor "value with spaces in braces"
    @command = command[:command].split(' ')
  end

  def apply_templates(command, command_params)
    templater = Templater.new(@container_api.system_value_access,nil)
    @image = templater.process_templated_string(@image)
    construct_cmdline(command, command_params, templater)
    apply_env_templates(command_params, templater) unless @environments.nil?
    apply_volume_templates(command_params, templater) unless @volumes.nil?
    apply_volume_from_templates(command_params, templater) unless @volumes_from.nil?
  end

  def apply_volume_templates(command_params, templater)
    @volumes.each_value do |volume|
      volume = symbolize_keys(volume)
      volume[:remotepath] = templater.apply_hash_variables(volume[:remotepath], command_params)
      volume[:localpath] = templater.apply_hash_variables(volume[:localpath], command_params)
      volume[:permissions] = templater.apply_hash_variables(volume[:permissions], command_params)
    end
  end

  def apply_volume_from_templates(command_params, templater)
    vols = []
    volumes_from.each do |from|
      s = templater.apply_hash_variables(from, command_params)
      vols.push(s) unless s == ""
    end
    @volumes_from = vols
    @volumes_from = nil if vols.size == 0
  end

  def apply_env_templates(command_params, templater)
    environments.each do |env|
      env.value = templater.apply_hash_variables(env.value, command_params)
    end
  end

  def resolved_strings(text, values_hash, templater)
    templater.apply_hash_variables(text, values_hash)
  end

  def check_params(cmd, params)
    r = true
    #   STDERR.puts('Command ' + cmd.to_s + ':' + params.to_s)
    cmd[:requires].each do |required_param|
      next if params.key?(required_param.to_sym)
      r = 'Missing:' if r == true
      r +=  ' ' + required_param.to_s
    end
    r
  end

#  def container_logs_as_result
#
#  end

  def clear_configs
    FileUtils.rm(ContainerStateFiles.container_state_dir(self) + '/running.yaml') if File.exist?(ContainerStateFiles.container_state_dir(self) + '/running.yaml')
    FileUtils.rm(ContainerStateFiles.container_state_dir(self) + '/running.yaml.bak') if File.exist?(ContainerStateFiles.container_state_dir(self) + '/running.yaml.bak')
  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :managed_utility,
      params: params }
  end
  
def accepts_stream?
   @accepts_stream |= false
 end

 def provides_stream?
   @provides_stream |= false
 end
end