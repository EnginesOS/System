class SystemApi
  attr_reader :last_error
  def initialize(api)
    @engines_api = api
  end

  def create_container(container)
    clear_error
    begin
      cid = read_container_id(container)
      container.container_id=(cid)
      stateDir = container_state_dir(container)
      if File.directory?(stateDir) ==false
        Dir.mkdir(stateDir)
        if  Dir.exists?(stateDir + '/run') == false
          Dir.mkdir(stateDir + '/run')
          Dir.mkdir(stateDir + '/run/flags')
        end
        FileUtils.chown_R(nil,'containers',stateDir + '/run')
        FileUtils.chmod_R('u+r',stateDir + '/run')
      end
      log_dir = container_log_dir(container)
      if File.directory?(log_dir) ==false
        p :mk_log_dir
        p log_dir
        Dir.mkdir(log_dir)
      end
      if container.is_service?
        if File.directory?(stateDir + '/configurations') ==false
          Dir.mkdir(stateDir + '/configurations/')
        end
        if File.directory?(stateDir + '/configurations/default') ==false
          Dir.mkdir(stateDir + '/configurations/default')
        end
      end
      return save_container(container)
    rescue Exception=>e
      container.last_error=('Failed To Create ' + e.to_s)
      SystemUtils.log_exception(e)
      return false
    end
  end

  def clear_cid(container)
    container.container_id=(-1)
  end

  def is_startup_complete container
    clear_error
    begin
      runDir=container_state_dir(container)
      if File.exists?(runDir + '/run/flags/startup_complete')
        return true
      else
        return false
      end
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def clear_cid_file container
    clear_error
    begin
      cidfile =  container_cid_file(container)
      if File.exists? cidfile
        File.delete cidfile
      end
      clear_cid(container)
      return true
    rescue Exception=>e
      container.last_error='Failed To remove cid file' + e.to_s
      SystemUtils.log_exception(e)
      return false
    end
  end

  def read_container_id(container)
    clear_error
    begin
      cidfile =  container_cid_file(container)
      if File.exists?(cidfile)
        cid = File.read(cidfile)
        return cid
      end
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return '-1';
    end
  end

  def destroy_container container
    clear_error
    begin
      container.container_id=(-1)
      if File.exists?( container_cid_file(container)) ==true
        File.delete( container_cid_file(container))
      end
      return true #File may or may not exist
    rescue Exception=>e
      container.last_error=( 'Failed To delete cid ' + e.to_s)
      SystemUtils.log_exception(e)
      return false
    end
  end

  def delete_container_configs(container)
    clear_error
    cidfile  = SystemConfig.CidDir + '/' + container.container_name + '.cid'
    if File.exists?(cidfile)
      File.delete(cidfile)
    end
    cmd = 'docker rm volbuilder'
    retval =  SystemUtils.run_system(cmd)
    cmd = 'docker run  --name volbuilder --memory=20m -e fw_user=www-data  -v /opt/engines/run/containers/' + container.container_name + '/:/client/state:rw  -v /var/log/engines/containers/' + container.container_name + ':/client/log:rw    -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh state logs'
    retval =  SystemUtils.run_system(cmd)
    cmd = 'docker rm volbuilder'
    retval =  SystemUtils.run_system(cmd)
    if retval == true
      FileUtils.rm_rf(container_state_dir(container))
      return true
    else
      container.last_error=('Failed to Delete state and logs:' + retval.to_s)
      SystemUtils.log_error_mesg('Failed to Delete state and logs:' + retval.to_s ,container)
      return false
    end
  rescue Exception=>e
    container.last_error=( 'Failed To Delete ' )
    SystemUtils.log_exception(e)
    return false
  end

#  def get_cert_name(fqdn)
#    if File.exists?(SystemConfig.NginxCertDir + '/' + fqdn + '.crt')
#      return  fqdn
#    else
#      return SystemConfig.NginxDefaultCert
#    end
#  end

  def get_build_report(engine_name)
    clear_error
    stateDir=SystemConfig.RunDir + '/containers/' + engine_name
    if File.exists?(stateDir  + '/buildreport.txt')
      return File.read(stateDir  + '/buildreport.txt')
    else
      return 'Build Not Successful'
    end

  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def save_build_report(container,build_report)
    clear_error
    stateDir=container_state_dir(container)
    f = File.new(stateDir  + '/buildreport.txt',File::CREAT|File::TRUNC|File::RDWR, 0644)
    f.puts(build_report)
    f.close
    return true
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def save_container(container)
    clear_error
    begin
      #FIXME
      api = container.core_api
      container.core_api = nil
      last_result = container.last_result
      last_error = container.last_error
      #   save_last_result_and_error(container)
      container.last_result=''
      container.last_error=''
      serialized_object = YAML::dump(container)
      container.core_api = api
      container.last_result = last_result
      container.last_error = last_error
      stateDir = container_state_dir(container)
      if Dir.exist?(stateDir) == false
        FileUtils.mkdir_p(stateDir)
      end        
      statefile=stateDir + '/running.yaml'
      # BACKUP Current file with rename
      if File.exists?(statefile)
        statefile_bak = statefile + '.bak'
        File.rename( statefile,   statefile_bak)
      end
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.puts(serialized_object)
      f.close
      return true
    rescue Exception=>e
      container.last_error=('save error')
      #FIXME Need to rename back if failure
      SystemUtils.log_exception(e)
      return false
    end
  end

  def save_blueprint(blueprint,container)
    clear_error
    begin
      if blueprint != nil
        puts blueprint.to_s
      else
        return false
      end
      stateDir=container_state_dir(container)
      if File.directory?(stateDir) ==false
        Dir.mkdir(stateDir)
      end
      statefile=stateDir + '/blueprint.json'
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.write(blueprint.to_json)
      f.close
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def load_blueprint(container)
    clear_error
    begin
      stateDir=container_state_dir(container)
      if File.directory?(stateDir) ==false
        return false
      end
      statefile=stateDir + '/blueprint.json'
      if File.exists?(statefile)
        f = File.new(statefile,'r')
        blueprint = JSON.parse( f.read())
        f.close
      else
        return false
      end
      return blueprint
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def get_container_memory_stats(container)
    clear_error
    ret_val= Hash.new
    begin
      if container && container.container_id == nil || container.container_id == '-1'
        container_id = read_container_id(container)
        container.container_id=(container_id)
      end
      if container && container.container_id != nil && container.container_id != '-1'
       # path = '/sys/fs/cgroup/memory/docker/' + container.container_id.to_s + '/'
           path = SystemUtils.cgroup_mem_dir(container.container_id.to_s)
        if Dir.exists?(path)
          ret_val.store(:maximum , File.read(path + '/memory.max_usage_in_bytes'))
          ret_val.store(:current , File.read(path + '/memory.usage_in_bytes'))
          ret_val.store(:limit , File.read(path + '/memory.limit_in_bytes'))
        else
          p :no_cgroup_file
          p path
          ret_val.store(:maximum ,  'No Container')
          ret_val.store(:current , 'No Container')
          ret_val.store(:limit ,  'No Container')
        end
      end
      return ret_val
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      ret_val.store(:maximum ,  e.to_s)
      ret_val.store(:current , 'NA')
      ret_val.store(:limit ,  'NA')
      return ret_val
    end
  end

  def set_engine_network_properties(engine, params)
    clear_error
    if set_engine_web_protocol_properties(engine, params)
      return   set_engine_hostname_details(engine,params)
    end
    return false
  end

  def set_engine_web_protocol_properties(engine, params)
    clear_error
    begin
#      engine_name = params[:engine_name]
      protocol = params[:http_protocol]
      if protocol.nil?
        p params
        return false
      end
      SystemUtils.debug_output('Changing protocol to _',  protocol )
      if protocol.include?('HTTPS only')
        engine.enable_https_only
      elsif protocol.include?('HTTP only')
        engine.enable_http_only
      elsif protocol.include?('HTTPS and HTTP')
        engine.enable_http_and_https
      end
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def set_engine_hostname_details(container,params)
    clear_error
    begin
#      engine_name = params[:engine_name]
      hostname = params[:host_name]
      domain_name = params[:domain_name]
      SystemUtils.debug_output('Changing Domainame to ' , domain_name)
#      saved_hostName = container.hostname
#      saved_domainName =  container.domain_name
      SystemUtils.debug_output('Changing Domainame to ' , domain_name)
      container.remove_nginx_service
      container.set_hostname_details(hostname,domain_name)
      save_container(container)
      container.add_nginx_service
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end



  def getManagedEngines()
    begin
      ret_val=Array.new
      Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
        yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
        if File.exists?(yfn) == true
          managed_engine = loadManagedEngine(contdir)
          if managed_engine.is_a?(ManagedEngine)
            ret_val.push(managed_engine)
          else
            log_error('failed to load ' + yfn)
          end
        end
      end
      return ret_val
    rescue Exception=>e
      SystemUtils.log_exception(e)
    end
  end

  def loadManagedEngine(engine_name)
    if engine_name == nil || engine_name.length ==0
      @last_error = 'No Engine Name'
      return false
    end
    begin
      yam_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
      if File.exists?(yam_file_name) == false
        log_error('no such file ' + yam_file_name )
        return false # return failed(yam_file_name,'No such configuration:','Load Engine')
      end
      yaml_file = File.read(yam_file_name)
      managed_engine = ManagedEngine.from_yaml( yaml_file,@engines_api)
      if(managed_engine == nil || managed_engine == false)
        p :from_yaml_returned_nil
        return false # failed(yam_file_name,'Failed to Load configuration:','Load Engine')
      end
      return managed_engine
    rescue Exception=>e
      if engine_name != nil
        if managed_engine !=nil
          managed_engine.last_error=( 'Failed To get Managed Engine ' +  engine_name + ' ' + e.to_s)
          log_error(managed_engine.last_error)
        end
      else
        log_error('nil Engine Name')
      end
      SystemUtils.log_exception(e)
      return false
    end
  end

  def build_running_service(service_name,service_type_dir)
    config_template_file_name = service_type_dir + service_name + '/config.yaml'
    if File.exists?(config_template_file_name) == false
      log_error('Running exits')
      return false
    end
    config_template = File.read(config_template_file_name)
    system_access = SystemAccess.new
    templator = Templater.new(system_access,nil)
    running_config = templator.process_templated_string(config_template)
    yam1_file_name =service_type_dir + service_name + '/running.yaml'
    yaml_file = File.new(yam1_file_name,'w+')
    yaml_file.write(running_config)
    yaml_file.close
    return true
  end

  def loadSystemService(service_name)
    return _loadManagedService(service_name,SystemConfig.RunDir + '/system_services/')
  end
  
  def  loadManagedService(service_name)
    return _loadManagedService(service_name,SystemConfig.RunDir + '/services/')
  end
  
  def _loadManagedService(service_name,service_type_dir)
    begin
      if service_name == nil || service_name.length ==0
        @last_error='No Service Name'
        return false
      end
      yam1_file_name = service_type_dir + service_name + '/running.yaml'
      
      if File.exists?(yam1_file_name) == false
        if  build_running_service(service_name,service_type_dir) == false
          log_error('No build_running_service file ' + service_type_dir + '/'+ service_name.to_s)
          return false # return failed(yam_file_name,'No such configuration:','Load Service')
        end
      end
      yaml_file = File.read(yam1_file_name)     
      # managed_service = YAML::load( yaml_file)
      if service_type_dir == '/sytem_services/'
        managed_service = SystemService.from_yaml(yaml_file,@engines_api)
      else
        managed_service = ManagedService.from_yaml(yaml_file,@engines_api)
      end
      if managed_service == nil
        p :load_managed_servic_failed
        log_error('load_managed_servic_failed loading:' + yam1_file_name.to_s + ' service name: ' + service_name.to_s )
        return false # return EnginsOSapiResult.failed(yam_file_name,'Fail to Load configuration:','Load Service')
      end
      return managed_service
    rescue Exception=>e
      if service_name != nil
        if managed_service !=nil
          managed_service.last_error = ('Failed To get Managed Engine ' +  service_name.to_s + ' ' + e.to_s)
          log_error(managed_service.last_error)
        end
      else
        log_error('nil Service Name')
      end
      SystemUtils.log_exception(e)
    end
  end

  def getManagedServices()
    begin
      ret_val=Array.new
      Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
        yfn =SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
        if File.exists?(yfn) == true
          managed_service =  loadManagedService(contdir)
          if managed_service
            ret_val.push(managed_service)
          end
        end
      end
      return ret_val
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def list_managed_engines
    clear_error
    ret_val=Array.new
    begin
      Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
        yfn =SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
        if File.exists?(yfn) == true
          ret_val.push(contdir)
        end
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return ret_val
    end
    return ret_val
  end

  def list_managed_services
    clear_error

    ret_val=Array.new
    begin
      Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
        yfn = SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
        if File.exists?(yfn) == true
          ret_val.push(contdir)
        end
      end
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return ret_val
    end
    return ret_val
  end

  def clear_container_var_run(container)
    clear_error
    begin
      dir = container_state_dir(container)
      if File.exists?(dir + '/startup_complete')
        File.unlink(dir + '/startup_complete')
      end
      return true
    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def generate_engines_user_ssh_key
    newkey = SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    if newkey.start_with?('-----BEGIN RSA PRIVATE KEY-----') == false
      @last_error = newkey
      return false
    end
    return newkey
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def update_public_key(key)
     SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_access_system_pub engines@172.17.42.1 /opt/engines/bin/update_access_system_pub.sh ' + key)
  end
  def regen_system_ssh_key
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_access_system_pub engines@172.17.42.1 /opt/engines/bin/regen_private.sh ')
  end
  
  def container_state_dir(container)
    return SystemConfig.RunDir + '/'  + container.ctype + 's/' + container.container_name
  end

  def system_update_status
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/deb_update_status engines@172.17.42.1 /opt/engines/bin/deb_update_status.sh')
  end

  def restart_system
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_system engines@172.17.42.1 /opt/engines/bin/restart_system.sh') }
    #FIXME check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    if res.status == 'run'
      return true
    end
    return false

  end

  def  update_system
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_system engines@172.17.42.1 /opt/engines/bin/update_system.sh') }
    #FIXME check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    if res.status == 'run'
      return true
    end
    return false
  end

  def update_engines_system_software
    result = SystemUtils.execute_command('sudo /opt/engines/scripts/_update_engines_system_software.sh ')
    if result[:result] == -1
      @last_error=result[:stderr]
        FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
            return false
   end
    if result[:stdout].include?('Already up-to-date')
      @last_error=result[:stdout]
      FileUtils.rm_f(SystemConfig.EnginesSystemUpdatingFlag)
      return false
    end
    res = Thread.new { SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_engines_system_software engines@172.17.42.1 /opt/engines/bin/update_engines_system_software.sh') }
    #FIXME check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    if res.status == 'run'
      @last_error=result[:stdout]
      return true
    end
    return false
  end

  def update_domain(params)
    old_domain_name=params[:original_domain_name]
    if  DNSHosting.update_domain(old_domain_name,params) == false
      return  false
    end
    if params[:self_hosted] == false
      return true
    end
    service_hash = Hash.new
    service_hash[:parent_engine]='system'
    service_hash[:variables] = Hash.new
    service_hash[:variables][:domainname] = params[:original_domain_name]
    service_hash[:service_handle]=params[:original_domain_name] + '_dns'
    service_hash[:container_type]='system'
    service_hash[:publisher_namespace]='EnginesSystem'
    service_hash[:type_path]='dns'
    @engines_api.dettach_service(service_hash)
    #@engines_api.deregister_non_persistant_service(service_hash)
    @engines_api.delete_service_from_engine_registry(service_hash)
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle]=params[:domain_name] + '_dns'
    if(params[:internal_only])
      ip = DNSHosting.get_local_ip
    else
      ip =  open( 'http://jsonip.com/' ){ |s| JSON::parse( s.string())['ip'] };
    end
    service_hash[:variables][:ip] = ip;
    if  @engines_api.attach_service(service_hash) == true
      @engines_api.register_non_persistant_service(service_hash)
      return true
    end
    return false
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def add_domain params
    if DNSHosting.add_domain(params) == false
      return false
    end
    if params[:self_hosted] == false
      return true
    end
    service_hash = Hash.new
    service_hash[:parent_engine]='system'
    service_hash[:variables] = Hash.new
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle]=params[:domain_name] + '_dns'
    service_hash[:container_type]='system'
    service_hash[:publisher_namespace]='EnginesSystem'
    service_hash[:type_path]='dns'
    if(params[:internal_only])
      ip = DNSHosting.get_local_ip
    else
      ip =  open( 'http://jsonip.com/' ){ |s| JSON::parse( s.string())['ip'] };
    end
    service_hash[:variables][:ip] = ip;

    if   @engines_api.attach_service(service_hash) == true
      @engines_api.register_non_persistant_service(service_hash)
      return true
    end
    return false
  rescue Exception=>e
    log_error('Add self hosted domain exception' + params.to_s)
    log_exception(e)
    return false
  end

  #FIXME Kludge should read from network namespace /proc ?
  def get_container_network_metrics(container_name)
    begin
      ret_val = Hash.new
      clear_error
      def error_result
        ret_val = Hash.new
        ret_val[:in]='n/a'
        ret_val[:out]='n/a'
        return ret_val
      end
      commandargs='docker exec ' + container_name + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 \' \' $6}'  2>&1"
      result = SystemUtils.execute_command(commandargs)
      if result[:result] != 0
        ret_val = error_result
      else
        res = result[:stdout]
        vals = res.split('bytes:')
        p res
        p vals
        if vals.count > 2
          if vals[1] != nil && vals[2] != nil
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
    rescue Exception=>e
      log_exception(e)
      return   error_result
    end
  end

  def remove_domain params
    if DNSHosting.rm_domain(params) == false
      p :remove_domain_last_error
      return  false
    end
    if params[:self_hosted] == false
      return true
    end
    service_hash = Hash.new
    service_hash[:parent_engine]='system'
    service_hash[:variables] = Hash.new
    service_hash[:variables][:domainname] = params[:domain_name]
    service_hash[:service_handle]=params[:domain_name] + '_dns'
    service_hash[:container_type]='system'
    service_hash[:publisher_namespace]='EnginesSystem'
    service_hash[:type_path]='dns'
    if  @engines_api.dettach_service(service_hash) == true
      @engines_api.deregister_non_persistant_service(service_hash)
      @engines_api.delete_service_from_engine_registry(service_hash)
      return true
    end
    return false
  rescue Exception=>e
    log_exception(e)
    return false
  end

  def list_domains
    return DNSHosting.list_domains( )
  rescue Exception=>e
    return log_exception(e)
  end

  protected

  def container_cid_file(container)
    return  SystemConfig.CidDir + '/'  + container.container_name + '.cid'
  end

  def container_log_dir container
    return SystemConfig.SystemLogRoot + '/'  + container.ctype + 's/' + container.container_name
  end

  def run_system (cmd)
    clear_error
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemUtils.debug_output('run System', res)
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?('error') == false && res.downcase.include?('fail') == false && res.downcase.include?('could not resolve hostname') == false && res.downcase.include?('unsuccessful') == false
        return true
      else
        return res
      end
    rescue Exception=>e
      log_exception(e)
      return res
    end
  end

  def clear_error
    @last_error = ''
  end

  def log_exception(e)
    @last_error= e.to_s + e.backtrace.to_s
  end
  def  log_error(e_str)
    @last_error = e_str
    SystemUtils.log_output(e_str,10)
    return false
  end

end #END of SystemApi
