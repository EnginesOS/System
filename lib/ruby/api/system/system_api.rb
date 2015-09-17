class SystemApi < ErrorsApi
  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
  end  

  def is_startup_complete(container)
    clear_error
    return File.exist?(ContainerStateFiles.container_state_dir(container) + '/run/flags/startup_complete')
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def get_build_report(engine_name)
    clear_error
    state_dir = SystemConfig.RunDir + '/containers/' + engine_name
    return File.read(state_dir + '/buildreport.txt') if File.exist?(state_dir + '/buildreport.txt')
    return 'Build Not Successful'
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def save_build_report(container, build_report)
    clear_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    f = File.new(state_dir  + '/buildreport.txt', File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(build_report)
    f.close
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def save_container(container)
    clear_error
    # FIXME:
    api = container.container_api
    container.container_api = nil
    last_result = container.last_result
  #  last_error = container.last_error
    # save_last_result_and_error(container)
    container.last_result = ''
  
    serialized_object = YAML.dump(container)
    container.container_api = api
   # container.last_result = last_result
    #container.last_error = last_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    FileUtils.mkdir_p(state_dir)  if Dir.exist?(state_dir) == false
    statefile = state_dir + '/running.yaml'
    # BACKUP Current file with rename
    if File.exist?(statefile)
      statefile_bak = statefile + '.bak'
      File.rename(statefile, statefile_bak)
    end
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.close
    return true
  rescue StandardError => e
    container.last_error = last_error
    # FIXME: Need to rename back if failure
    SystemUtils.log_exception(e)
  end



  def get_container_memory_stats(container)
    clear_error
    ret_val = {}
    if container && container.container_id.nil? || container.container_id == '-1'
      container_id = ContainerStateFiles.read_container_id(container)
     
    end
    if container && container.container_id.nil? == false && container.container_id != '-1'
      # path = '/sys/fs/cgroup/memory/docker/' + container.container_id.to_s + '/'
      path = SystemUtils.cgroup_mem_dir(container.container_id.to_s)
      if Dir.exist?(path)
        ret_val.store(:maximum, File.read(path + '/memory.max_usage_in_bytes'))
        ret_val.store(:current, File.read(path + '/memory.usage_in_bytes'))
        ret_val.store(:limit, File.read(path + '/memory.limit_in_bytes'))
      else
        log_error_mesg('no_cgroup_file for ' + container.container_name, path)
        ret_val.store(:maximum, 'No Container')
        ret_val.store(:current, 'No Container')
        ret_val.store(:limit, 'No Container')
      end
    end
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    ret_val.store(:maximum, e.to_s)
    ret_val.store(:current, 'NA')
    ret_val.store(:limit, 'NA')
    return ret_val
  end

  def set_engine_network_properties(engine, params)
    clear_error
    return set_engine_hostname_details(engine, params) if set_engine_web_protocol_properties(engine, params)
    return false
  end

  def set_engine_web_protocol_properties(engine, params)
    clear_error
    #      engine_name = params[:engine_name]
    protocol = params[:http_protocol]
    return false if protocol.nil?
    SystemUtils.debug_output('Changing protocol to _', protocol)
    if protocol.include?('HTTPS only')
      engine.enable_https_only
    elsif protocol.include?('HTTP only')
      engine.enable_http_only
    elsif protocol.include?('HTTPS and HTTP')
      engine.enable_http_and_https
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def set_engine_hostname_details(container, params)
    clear_error
    #      engine_name = params[:engine_name]
    hostname = params[:host_name]
    domain_name = params[:domain_name]
    SystemUtils.debug_output('Changing Domainame to ', domain_name)
    #      saved_hostName = container.hostname
    #      saved_domainName =  container.domain_name
    SystemUtils.debug_output('Changing Domainame to ', domain_name)
    container.remove_nginx_service
    container.set_hostname_details(hostname, domain_name)
    save_container(container)
    container.add_nginx_service
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def getManagedEngines
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
      yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
      if File.exist?(yfn)
        managed_engine = loadManagedEngine(contdir)
        if managed_engine.is_a?(ManagedEngine)
          ret_val.push(managed_engine)
        else
          log_error_mesg('failed to load ', yfn)
        end
      end
    end
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def loadManagedEngine(engine_name)
    p :load_me
    p engine_name
    e = engine_from_cache(engine_name)
    return e unless e.nil?
           
    return log_error_mesg('No Engine name', engine_name) if engine_name.nil? || engine_name.length == 0
    yam_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
    return log_error_mesg('No Engine file', engine_name) unless File.exist?(yam_file_name)
    yaml_file = File.read(yam_file_name)
    managed_engine = ManagedEngine.from_yaml(yaml_file, @engines_api.container_api)    
    return false if managed_engine.nil? || managed_engine == false
    cache_engine(engine_name,managed_engine)
    return managed_engine
  rescue StandardError => e
    unless engine_name.nil?
      unless managed_engine.nil?
        managed_engine.last_error = 'Failed To get Managed Engine ' + engine_name + ' ' + e.to_s
        log_error_mesg(managed_engine.last_error, e)
      end
    else
      log_error_mesg('nil Engine Name', engine_name)
    end
    log_exception(e)
  end

  def loadSystemService(service_name)
    _loadManagedService(service_name, SystemConfig.RunDir + '/system_services/')
  end

  def loadManagedService(service_name)
    s = engine_from_cache('/services/' + service_name)
    p :service_from_cache unless s.nil?
            return s unless s.nil?            
   s = _loadManagedService(service_name, SystemConfig.RunDir + '/services/')
    cache_engine('/services/' + service_name, s)
    p :loaded_service
    p service_name
    return s
  end

  def _loadManagedService(service_name, service_type_dir)
  
    if service_name.nil? || service_name.length == 0
      @last_error = 'No Service Name'
      return false
    end
    yam1_file_name = service_type_dir + service_name + '/running.yaml'
    unless File.exist?(yam1_file_name)
      return log_error_mesg('failed to create service file ', service_type_dir + '/' + service_name.to_s) unless ContainerStateFiles.build_running_service(service_name, service_type_dir)
    end
    yaml_file = File.read(yam1_file_name)
    # managed_service = YAML::load( yaml_file)
    managed_service = SystemService.from_yaml(yaml_file, @engines_api.service_api) if service_type_dir == '/sytem_services/'
    managed_service = ManagedService.from_yaml(yaml_file, @engines_api.service_api)
    return log_error_mesg('Failed to load', yaml_file) if managed_service.nil?
    
    managed_service
  rescue StandardError => e
    if service_name.nil? == false
      unless managed_service.nil?
        managed_service.last_error = ('Failed To get Managed Engine ' + service_name.to_s + ' ' + e.to_s)
        log_exception(e)
      end
    else
      log_error_mesg('nil Service Name', service_name)
    end
    log_exception(e)
  end
  
  def engine_from_cache(ident)
    
    return  @engines_conf_cache[ident.to_sym] if @engines_conf_cache.key?(ident.to_sym)
    return nil
  end
  
  def delete_engine(engine_name)
    @engines_conf_cache.delete(engine_name.to_sym)
  end
  
  def cache_engine(ident, engine)
    @engines_conf_cache[ident.to_sym] = engine 
Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
  end
  
 
  
  def getManagedServices
    begin
      ret_val = []
      Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
        yfn = SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
        if File.exist?(yfn) == true
          managed_service = loadManagedService(contdir)
          ret_val.push(managed_service) if managed_service
        end
      end
      return ret_val
    rescue StandardError => e
      log_exception(e)
    end
  end

  def list_managed_engines
    clear_error
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
      yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
      ret_val.push(contdir) if File.exist?(yfn)
    end
    return ret_val
  rescue StandardError => e
    log_exception(e)
    return ret_val
  end

  def list_managed_services
    clear_error
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
      yfn = SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
      ret_val.push(contdir) if File.exist?(yfn)
    end
    return ret_val
  rescue StandardError => e
    log_exception(e)
    return ret_val
  end


  def generate_engines_user_ssh_key
    newkey = SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    return log_error_mesg("Not an RSA key",newkey) unless newkey.start_with?('-----BEGIN RSA PRIVATE KEY-----')
    return newkey
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def update_public_key(key)
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_access_system_pub engines@172.17.42.1 /opt/engines/bin/update_access_system_pub.sh ' + key)
  end

  def regen_system_ssh_key
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_access_system_pub engines@172.17.42.1 /opt/engines/bin/regen_private.sh ')
  end


  def system_update_status
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/deb_update_status engines@172.17.42.1 /opt/engines/bin/deb_update_status.sh')
  end

  def restart_system
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_system engines@172.17.42.1 /opt/engines/bin/restart_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
    return false
  end

  def update_system
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_system engines@172.17.42.1 /opt/engines/bin/update_system.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
  end

  def update_engines_system_software
    result = SystemUtils.execute_command('sudo /opt/engines/scripts/_update_engines_system_software.sh ')
    if result[:result] == -1
      @last_error = result[:stderr]
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      return false
    end
    # FIXME: The following was commented out so as to follow update cycle regardless of update status
#    if result[:stdout].include?('Already up-to-date')
#      @last_error = result[:stdout]
#      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
#      return false
#    end
    res = Thread.new { SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@172.17.42.1 /opt/engines/bin/update_engines_system_software.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    @last_error = result[:stdout]
    return true if res.status == 'run'
    return false
  end

  # FIXME: Kludge should read from network namespace /proc ?
  def get_container_network_metrics(container_name)
    ret_val = {}
    clear_error

    def error_result
      ret_val = {}
      ret_val[:in] = 'n/a'
      ret_val[:out] = 'n/a'
      return ret_val
    end
    commandargs = 'docker exec ' + container_name + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 \' \' $6}'  2>&1"
    result = SystemUtils.execute_command(commandargs)
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
      return ret_val
    end
  rescue StandardError => e
    log_exception(e)
    return error_result
  end
  
  def api_shutdown
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
  end
end
