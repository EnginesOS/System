module Container
  class ManagedUtility< ManagedContainer
    require_relative 'managed_utility_on_action.rb'
    include ManagedUtilityOnAction
    class << self
      def store
        @@utility_store ||= UtilityStore.new
      end
    end

    def ctype
      @ctype ||= 'utility'
    end
    
    def post_load
      # Basically parent super but no lock on image
      expire_engine_info
      begin
        info = container_dock.inspect_container_by_name(container_name)
        id = info[:Id] if info.is_a?(Hash)
      rescue
      end
      set_running_user
      self.domain_name = SystemConfig.internal_domain
      self.repository = '' if repository.nil?
      container_mutex = Mutex.new
    end

    def drop_log_dir
      volumes.delete(:log_dir)
    end

    def drop_state_dir
      volumes.delete(:state_dir)
    end

    def command_details(command_name)
      raise EnginesException.new(error_hash('No Commands', command_name)) unless commands.is_a?(Hash)
      if commands.key?(command_name)
        commands[command_name]
      else
        raise EnginesException.new(error_hash('Command not found _', command_name.to_s ))
      end
    end

    def execute_command(command_name, command_params)
      
       STDERR.puts("\n EXECutre Cmd " + command.to_s + ':' + command_params.to_s)
      if is_active?
        begin
        STDERR.puts('FS is active')
        expire_engine_info
        wait_for('stop', 120)
        raise EnginesException.new(error_hash('Utility Still active ' + container_name + ' in use ', command_name)) if is_active?
        destroy_container
      rescue
        end
      end

      r = ''
      STDERR.puts(" Command #{commands[command_name]} ")
      raise EnginesException.new(error_hash("No such command: #{command_name} (#{command_name.class.name} in #{commands}" ,  command_params)) unless commands.key?(command_name)
      command = command_details(command_name)
      raise EnginesException.new(error_hash('Missing params in Exe' + command_params.to_s + ' for ' + command_name.to_s, r)) unless (r = check_params(command, command_params)) == true
      begin
        destroy_container
      rescue
      end
      STDERR.puts('Wait for utili nocontainer')
      wait_for(:nocontainer) if has_container?
      begin
        container_dock.destroy_container(self) if has_container?
        wait_for(:nocontainer)
      rescue StandardError =>e
        STDERR.puts("E  #{e}")
      end
      raise EnginesException.new(error_hash('cant nocontainer Utility ' + command.to_s, command_params.to_s)) if has_container?
      STDERR.puts(' utili is nocontainer') 
      clear_configs
      STDERR.puts('cleared _configs')
      apply_templates(command, command_params)
      STDERR.puts('applied_templates')
      save_state
      STDERR.puts('saved_state')
      create_container
      STDERR.puts('created container')
    end

    def construct_cmdline(command, command_params, templater)
      command = templater.apply_hash_variables(command, command_params)
      #FixME as will not honor "value with spaces in braces"
      command = command[:command].split(' ')
    end

    def apply_templates(command, command_params)
      templater = Templater.new(nil)
      self.image = templater.process_templated_string(image)
      construct_cmdline(command, command_params, templater)
      apply_env_templates(command_params, templater) unless environments.nil?
      apply_volume_templates(command_params, templater) unless volumes.nil?
      STDERR.puts("VOLUMES" * 10)
      STDERR.puts("#{volumes_from}")
      apply_volume_from_templates(command_params, templater) unless volumes_from.nil?
    end

    def apply_volume_templates(command_params, templater)
      volumes.each_value do |volume|
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
      volumes_from = vols
      volumes_from = nil if vols.size == 0
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
      if cmd.nil?
        STDERR.puts('Command ' + cmd.to_s + ':' + params.to_s)
        r = false
      else
        cmd[:requires].each do |required_param|
          next if params.key?(required_param.to_sym)
          r = 'Missing:' if r == true
          r +=  " #{required_param}"
        end
      end
      r
    end

    def clear_configs
      expire_engine_info
      FileUtils.rm(store.file_name(container_name)) if File.exist?(store.file_name(container_name))
      FileUtils.rm("#{store.file_name(container_name)}.bak") if File.exist?("#{store.file_name(container_name)}.bak")
      STDERR.puts "DIR_" * 30
      STDERR.puts( "DR #{Dir.entries('/opt/engines/run/utilitys/fsconfigurator')}")
      expire_engine_info
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
end
