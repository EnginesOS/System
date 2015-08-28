class SystemApi < ErrorsApi
  def initialize(api)
    @engines_api = api
  end

  def create_container(container)
    clear_error
    cid = read_container_id(container)
    container.container_id = cid
    state_dir = container_state_dir(container)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      unless Dir.exist?(state_dir + '/run')
        Dir.mkdir(state_dir + '/run')
        Dir.mkdir(state_dir + '/run/flags')
      end
      FileUtils.chown_R(nil, 'containers', state_dir + '/run')
      FileUtils.chmod_R('u+r', state_dir + '/run')
    end
    log_dir = container_log_dir(container)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    if container.is_service?
      Dir.mkdir(state_dir + '/configurations/') unless File.directory?(state_dir + '/configurations')
      Dir.mkdir(state_dir + '/configurations/default') unless File.directory?(state_dir + '/configurations/default')
    end
    return save_container(container)
  rescue StandardError => e
    container.last_error = 'Failed To Create ' + e.to_s
    SystemUtils.log_exception(e)
  end

  def clear_cid(container)
    container.container_id = -1
  end

  def is_startup_complete(container)
    clear_error
    return File.exist?(container_state_dir(container) + '/run/flags/startup_complete')
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def clear_cid_file container
    clear_error
    cidfile = container_cid_file(container)
    File.delete(cidfile) if File.exist?(cidfile)
    clear_cid(container)
    return true
  rescue StandardError => e
    container.last_error = 'Failed To remove cid file' + e.to_s
    SystemUtils.log_exception(e)
  end

  def read_container_id(container)
    clear_error
    cidfile = container_cid_file(container)
    return File.read(cidfile) if File.exist?(cidfile)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return '-1'
  end

  def destroy_container container
    clear_error
    container.container_id = -1
    return File.delete(container_cid_file(container)) if File.exist?(container_cid_file(container))
    return true # File may or may not exist
  rescue StandardError => e
    container.last_error = 'Failed To delete cid ' + e.to_s
    SystemUtils.log_exception(e)
  end

  def delete_container_configs(container)
    clear_error
    cidfile = SystemConfig.CidDir + '/' + container.container_name + '.cid'
    File.delete(cidfile) if File.exist?(cidfile)
    cmd = 'docker rm volbuilder'
    retval = SystemUtils.run_system(cmd)
    cmd = 'docker run  --name volbuilder --memory=20m -e fw_user=www-data  -v /opt/engines/run/containers/' + container.container_name + '/:/client/state:rw  -v /var/log/engines/containers/' + container.container_name + ':/client/log:rw    -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh state logs'
    retval = SystemUtils.run_system(cmd)
    cmd = 'docker rm volbuilder'
    retval =  SystemUtils.run_system(cmd)
    if retval == true
      FileUtils.rm_rf(container_state_dir(container))
      return true
    else
      container.last_error = 'Failed to Delete state and logs:' + retval.to_s
      log_error_mesg('Failed to Delete state and logs:' + retval.to_s, container)
    end
  rescue StandardError => e
    container.last_error = 'Failed To Delete '
    log_exception(e)
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
    state_dir = container_state_dir(container)
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
    last_error = container.last_error
    # save_last_result_and_error(container)
    container.last_result = ''
    container.last_error = ''
    serialized_object = YAML.dump(container)
    container.container_api = api
    container.last_result = last_result
    container.last_error = last_error
    state_dir = container_state_dir(container)
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

  def save_blueprint(blueprint, container)
    clear_error
    return false if blueprint.nil?
    puts blueprint.to_s
    state_dir = container_state_dir(container)
    Dir.mkdir(state_dir) if File.directory?(state_dir) == false
    statefile = state_dir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def load_blueprint(container)
    clear_error
    state_dir = container_state_dir(container)
    return false unless File.directory?(state_dir)
    statefile = state_dir + '/blueprint.json'
    if File.exist?(statefile)
      f = File.new(statefile, 'r')
      blueprint = JSON.parse(f.read)
      f.close
    else
      return false
    end
    return blueprint
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def get_container_memory_stats(container)
    clear_error
    ret_val = {}
    if container && container.container_id.nil? || container.container_id == '-1'
      container_id = read_container_id(container)
      container.container_id = container_id
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
    return log_error_mesg('No Engine name', engine_name) if engine_name.nil? || engine_name.length == 0
    yam_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
    return log_error_mesg('No Engine file', engine_name) unless File.exist?(yam_file_name)
    yaml_file = File.read(yam_file_name)
    managed_engine = ManagedEngine.from_yaml(yaml_file, @engines_api.container_api)
    return false if managed_engine.nil? || managed_engine == false
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

  def build_running_service(service_name, service_type_dir)
    config_template_file_name = service_type_dir + service_name + '/config.yaml'
    return log_error_mesg('Running exits', service_name) unless File.exist?(config_template_file_name)
    config_template = File.read(config_template_file_name)
    templator = Templater.new(SystemAccess.new, nil)
    running_config = templator.process_templated_string(config_template)
    yam1_file_name = service_type_dir + service_name + '/running.yaml'
    yaml_file = File.new(yam1_file_name, 'w+')
    yaml_file.write(running_config)
    yaml_file.close
  end

  def loadSystemService(service_name)
    _loadManagedService(service_name, SystemConfig.RunDir + '/system_services/')
  end

  def loadManagedService(service_name)
    _loadManagedService(service_name, SystemConfig.RunDir + '/services/')
  end

  def _loadManagedService(service_name, service_type_dir)
    if service_name.nil? || service_name.length == 0
      @last_error = 'No Service Name'
      return false
    end
    yam1_file_name = service_type_dir + service_name + '/running.yaml'
    unless File.exist?(yam1_file_name)
      return log_error_mesg('No build_running_service file ', service_type_dir + '/' + service_name.to_s) unless build_running_service(service_name, service_type_dir)
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

  def clear_container_var_run(container)
    clear_error
    File.unlink(container_state_dir(container) + '/startup_complete') if File.exist?(container_state_dir(container) + '/startup_complete')
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
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

  def container_state_dir(container)
    SystemConfig.RunDir + '/' + container.ctype + 's/' + container.container_name
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
    if result[:stdout].include?('Already up-to-date')
      @last_error = result[:stdout]
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      return false
    end
    res = Thread.new { SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@172.17.42.1 /opt/engines/bin/update_engines_system_software.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    @last_error = result[:stdout]
    return true if res.status == 'run'
    return false
  end

  def update_domain(params)
    old_domain_name = params[:original_domain_name]
    return false unless DNSHosting.update_domain(old_domain_name, params)
    return true unless params[:self_hosted]
    service_hash =  {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domainname] = params[:original_domain_name]
    service_hash[:service_handle] = params[:original_domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    @engines_api.dettach_service(service_hash)
    # @engines_api.deregister_non_persistant_service(service_hash)
    # @engines_api.delete_service_from_engine_registry(service_hash)
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
    return @engines_api.register_non_persistant_service(service_hash) if @engines_api.attach_service(service_hash)
    return false
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def add_domain(params)
    return false unless DNSHosting.add_domain(params)
    return true unless params[:self_hosted]
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
    return @engines_api.service_manager.register_non_persistant_service(service_hash) if @engines_api.attach_service(service_hash)
    return false
  rescue StandardError => e
    log_error_mesg('Add self hosted domain exception', params.to_s)
    log_exception(e)
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

  def remove_domain(params)
    return false if DNSHosting.rm_domain(params) == false
    return true if params[:self_hosted] == false
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    if @engines_api.dettach_service(service_hash) == true
      @engines_api.deregister_non_persistant_service(service_hash)
      @engines_api.delete_service_from_engine_registry(service_hash)
      return true
    end
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def list_domains
    return DNSHosting.list_domains
  rescue StandardError => e
    log_exception(e)
  end

  protected

  def get_ip_for_hosted_dns(internal)
    return DNSHosting.get_local_ip if internal
    open('http://jsonip.com/') { |s| JSON::parse(s.string)['ip'] }
  end

  def container_cid_file(container)
    SystemConfig.CidDir + '/' + container.container_name + '.cid'
  end

  def container_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end

  def run_system(cmd)
    clear_error
    begin
      cmd += ' 2>&1'
      res = (%x<#{cmd}>)
      SystemUtils.debug_output('run System', res)
      # FIXME: should be case insensitive The last one is a pure kludge
      # really need to get stderr and stdout separately
      return true if $CHILD_STATUS == 0 && res.downcase.include?('error') == false && res.downcase.include?('fail') == false && res.downcase.include?('could not resolve hostname') == false && res.downcase.include?('unsuccessful') == false
      return res
    rescue StandardError => e
      log_exception(e)
      return res
    end
  end
end
