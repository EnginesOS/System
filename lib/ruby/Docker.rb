class Docker
  def initialize

  end

 attr_reader :last_error
    
  def run_docker (args,container)
    clear_error
    require 'open3'

    res = String.new
    error_mesg = String.new
    begin
      container.last_result=(  "")
      Open3.popen3("docker " + args ) do |stdin, stdout, stderr, th|
        oline = String.new
        stderr_is_open=true
        begin
          stdout.each { |line|
            line = line.gsub(/\\\"/,"")
            oline = line
            res += line.chop
            if stderr_is_open
              error_mesg += stderr.read_nonblock(1000)
            end
          }
        rescue Errno::EIO
          res += oline.chop
          error_mesg += stderr.read_nonblock(1000)
        rescue  IO::WaitReadable
          retry
        rescue EOFError
          if stdout.closed? == false
            stderr_is_open = false
            retry
          else
            container.last_result=(  res)
            container.last_error=( error_mesgs)
          end
        end

        if error_mesg.include?("Error")
          container.last_error=(error_mesg)
          p "docker_cmd error " + error_mesg
          return false
        else
          container.last_error=("")
        end

        if res.start_with?("[") == true
          res = res +"]"
        end
        container.last_result=(res)
        return true
      end
    rescue
      container.last_result=(  res)
      container.last_error=( error_mesgs)
      return false

    end

    return true
  end

  def run_system (cmd)
    clear_error
    begin
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>
      p res
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
        return true
      else
        return res
      end
    rescue Exception=>e
      log_error(e)
      return ret_val
    end
  end

  def list_managed_engines
    clear_error
    ret_val=Array.new
    begin
      Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
        yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"
        if File.exists?(yfn) == true
          ret_val.push(contdir)
        end
      end
    rescue Exception=>e
      log_error(e)
      return ret_val
    end
    return ret_val
  end

  def list_managed_services
    clear_error

    ret_val=Array.new
    begin
      Dir.entries(SysConfig.CidDir + "/services/").each do |contdir|
        yfn = SysConfig.CidDir + "/services/" + contdir + "/config.yaml"
        if File.exists?(yfn) == true
          ret_val.push(contdir)
        end
      end
    rescue  Exception=>e
      log_error(e)
      return ret_val
    end
    return ret_val

  end

  def delete_image container
    clear_error
    begin
      commandargs= " rmi " +   container.image
      ret_val =  run_docker(commandargs,container)

      if ret_val == true #only delete if sucessful or no such container
        stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
        FileUtils.rm_rf  stateDir
      end

      #kludge
      if ret_val == false
        container.last_error.include?("No such image")
        stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
        FileUtils.rm_rf  stateDir
      end
      return ret_val
    rescue Exception=>e
      container.last_error=( "Failed To Delete " + e.to_s)
      log_error(e)
      return false
    end
  end

  def destroy_container container
    clear_error
    begin
      commandargs= " rm " +   container.containerName

      ret_val = run_docker(commandargs,container)
      if (ret_val == true) #FIXME need to remove .cid if no such container but keep if container failed to stop
        container.container_id  = nil
        if File.exists?(SysConfig.CidDir + "/" + container.containerName + ".cid") ==true
          File.delete(SysConfig.CidDir + "/" + container.containerName + ".cid")
        end
      end
      return ret_val

    rescue Exception=>e
      container.last_error=( "Failed To Destroy " + e.to_s)
      log_error(e)
      return false
    end
  end

  def container_commandline_args container
    clear_error
    begin
      e_option =String.new

      clear_container_var_run(container)

      eportoption = String.new
      if(container.environments)
        container.environments.each do |environment|
          if environment != nil
            e_option = e_option + " -e " + environment.name + "=\"" + environment.value + "\""
          end
        end
      end

      volume_option = get_volume_option container

      if(container.eports )
        container.eports.each do |eport|
          if eport != nil

            eportoption = eportoption +  " -p "
            if eport.external >0
              eportoption = eportoption + eport.external.to_s + ":"
            end
            eportoption = eportoption + eport.port.to_s
            if eport.proto_type == nil
              eport.set_proto_type 'tcp'
            end
            eportoption = eportoption + "/"+ eport.proto_type + " "
          end
        end
      end

      if container.conf_self_start == false
        start_cmd=" /bin/bash /home/init.sh"
      else
        start_cmd=" "
      end
      commandargs =  "-h " + container.hostName + e_option + " --memory=" + container.memory.to_s + "m " + volume_option + eportoption + " --cidfile " + SysConfig.CidDir + "/" + container.containerName + ".cid --name " + container.containerName + "  -t " + container.image + start_cmd

      return commandargs
    rescue Exception=>e
      log_error(e)
      return nil
    end
  end

  def run_volume_builder (container,username)
    clear_error
    begin
      #FIXME use sysconfig for dir
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      mapped_vols = get_volbuild_volmaps container
      command = "docker run --name volbuilder --memory=20m -e fw_user=" + username + " --cidfile /opt/engines/run/volbuilder.cid " + mapped_vols + " -t engines/volbuilder /bin/sh /home/setup_vols.sh "
      p command
      run_system(command)
      command = "docker stop volbuilder;  docker rm volbuilder"
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      run_system(command)
    rescue Exception=>e
      log_error(e)
      return false
    end
  end

  def create_container container
    clear_error
    begin
      commandargs = container_commandline_args container
      commandargs = " run  -d " + commandargs
      p commandargs
      cidfile = SysConfig.CidDir + "/"  + container.containerName + ".cid"
      if File.exists? cidfile
        File.delete cidfile
      end
      retval = run_docker(commandargs,container)
      if retval == true #FIXME KLUDGE ALERT needs to be done better in docker api
        container_id = read_container_id(container.containerName)
        container.container_id = container_id
      end
      return retval
    rescue Exception=>e
      container.last_error=("Failed To Create " + e.to_s)
      log_error(e)
      return false
    end
  end

  def read_container_id containerName
    clear_error
    begin
      cidfile = SysConfig.CidDir + "/"  + containerName + ".cid"

      if File.exists?(cidfile)
        cid = File.read(cidfile)
        return cid
      end
    rescue  Exception=>e
      log_error(e)
      return "-1";
    end
  end

  def rebuild_image container
    clear_error
    begin
      builder = EngineBuilder.new(container.repo,container.hostName,container.domainName,container.environments, container.docker_api)

      return  builder.rebuild_managed_container(container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def start_container   container
    clear_error
    begin
      commandargs =" start " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def stop_container container
    clear_error
    begin
      commandargs=" stop " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def pause_container container
    clear_error
    begin
      commandargs = " pause " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def unpause_container container
    clear_error
    begin
      commandargs=" unpause " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def ps_container container
    clear_error
    begin
      commandargs=" top " + container.containerName + " axl"
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      rturn false
    end
  end

  def logs_container container
    clear_error
    begin
      commandargs=" logs " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def inspect_container container
    clear_error
    begin
      commandargs=" inspect " + container.containerName
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def register_dns(top_level_hostname,ip_addr_str)  # no Gem made this simple (need to set tiny TTL) and and all used nsupdate anyhow
    clear_error
    begin
      fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
      #FIXME need unique name for temp file
      dns_cmd_file_name="/tmp/.dns_cmd_file"
      dns_cmd_file = File.new(dns_cmd_file_name,"w+")
      dns_cmd_file.puts("server " + SysConfig.defaultDNS)
      dns_cmd_file.puts("update delete " + fqdn_str)
      dns_cmd_file.puts("send")
      dns_cmd_file.puts("update add " + fqdn_str + " 30 A " + ip_addr_str)
      dns_cmd_file.puts("send")
      dns_cmd_file.close
      cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name
      retval = run_system(cmd_str)
      File.delete(dns_cmd_file_name)
      return retval
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def deregister_dns(top_level_hostname)
    clear_error
    begin
      fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
      #FIXME need unique name
      dns_cmd_file_name="/tmp/.dns_cmd_file"
      dns_cmd_file = File.new(dns_cmd_file_name,"w")
      dns_cmd_file.puts("server " + SysConfig.defaultDNS)
      dns_cmd_file.puts("update delete " + fqdn_str)
      dns_cmd_file.puts("send")
      dns_cmd_file.close
      cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name
      retval =  run_system(cmd_str)
      File.delete(dns_cmd_file_name)
      return retval
    rescue  Exception=>e
      log_error(e)
      return false
    end

  end

  def register_site(site_hash)
    clear_error
    begin
      # ssh_cmd=SysConfig.addSiteCmd + " \"" + hash_to_site_str(site_hash)   +  "\""
      ssh_cmd = "/opt/engines/scripts/nginx/addsite.sh " + " \"" + hash_to_site_str(site_hash)   +  "\""
      p ssh_cmd
      result = run_system(ssh_cmd)

      result = restart_nginx_process()
      #run_system(ssh_cmd)
      return result
    rescue  Exception=>e
      log_error(e)
      return false
    end

  end

  def hash_to_site_str(site_hash)
    clear_error
    begin

      return site_hash[:name].to_s + ":" +  site_hash[:fqdn].to_s + ":" + site_hash[:port].to_s  + ":" + site_hash[:proto].to_s

    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def deregister_site(site_hash)
    clear_error
    begin
      #  ssh_cmd=SysConfig.rmSiteCmd +  " \"" + hash_to_site_str(site_hash) +  "\""
      #FIXME Should write site conf file via template (either standard or supplied with blueprint)
      ssh_cmd = "/opt/engines/scripts/nginx/rmsite.sh " + " \"" + hash_to_site_str(site_hash)   +  "\""
      p ssh_cmd
      result = run_system(ssh_cmd)
      result = restart_nginx_process()

      return result
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def add_ftp_service(site_hash)
    clear_error
    begin
      p site_hash
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def rm_ftp_service(site_hash)
    clear_error
    begin
      p site_hash
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def add_monitor(site_hash)
    clear_error
    begin

      ssh_cmd=SysConfig.addSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
      return run_system(ssh_cmd)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def rm_monitor(site_hash)
    clear_error
    begin

      ssh_cmd=SysConfig.rmSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
      return run_system(ssh_cmd)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def save_container container
    clear_error
    begin
      serialized_object = YAML::dump(container)
      stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
      if File.directory?(stateDir) ==false
        Dir.mkdir(stateDir)
        Dir.mkdir(stateDir + "/run")

        log_dir = container_log_dir(container)
        if File.directory?(log_dir) ==false
          Dir.mkdir(log_dir)
        end
      end
      statefile=stateDir + "/config.yaml"
      # BACKUP Current file with rename
      if File.exists?(statefile)
        statefile_bak = statefile + ".bak"
        File.rename( statefile,   statefile_bak)
      end
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.puts(serialized_object)
      f.close
      return true
    rescue Exception=>e
      container.last_error=( e.message)
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
      stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
      if File.directory?(stateDir) ==false
        Dir.mkdir(stateDir)
      end
      statefile=stateDir + "/blueprint.json"
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.write(blueprint.to_json)
      f.close
    rescue  Exception=>e
      log_error(e)
      return false
    end

  end

  def load_blueprint(container)
    clear_error
    begin
      stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
      if File.directory?(stateDir) ==false
        return false
      end
      statefile=stateDir + "/blueprint.json"
      f = File.new(statefile,"r")
      blueprint = JSON.parse( f.read())
      f.close

      return blueprint
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def create_database  site_hash
    clear_error
    begin
      container_name =  site_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /bin/sh -c \"/home/createdb.sh " + site_hash[:name] + " " + site_hash[:user] + " " + site_hash[:pass]+ "\""
      puts(cmd)

      return run_system(cmd)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def add_volume(site_hash)
    clear_error
    begin
      if Dir.exists?(  site_hash[:localpath] ) == false
        FileUtils.mkdir_p( site_hash[:localpath])
      end
      #currently the build scripts do this
      return true
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def rm_volume(site_hash)
    clear_error
    begin
      puts "would remove " + site_hash[:localpath]
      return true
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def rm_backup(site_hash)
    clear_error
    begin
      ssh_cmd=SysConfig.rmBackupCmd + " " + site_hash[:name]
      return run_system(ssh_cmd)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def create_backup(site_hash)
    clear_error
    begin
      containerName = site_hash[:engine_name]
      p site_hash
      if site_hash[:source_type] =="fs"
        site_src=containerName + ":fs:" + site_hash[:source_name]
      else
        site_src=containerName + ":" + site_hash[:source_type] + ":" +  site_hash[:source_user] +":" +  site_hash[:source_pass] + "@" +  site_hash[:source_host] + "/" + site_hash[:source_name]
      end

      site_dest=site_hash[:dest_proto] +":" + site_hash[:dest_user] + ":" + site_hash[:dest_pass] + "@" +  site_hash[:dest_address] + "/" + site_hash[:dest_folder]
      ssh_cmd=SysConfig.addBackupCmd + " " + site_hash[:name] + " " + site_src + " " + site_dest
      return run_system(ssh_cmd)
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def add_self_hosted_domain params
    clear_error
    begin

      return EnginesOSapiResult.new(true,0,params[:domain_name], "OK","Add self hosted domain")
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end
  #
  #
  #    site_hash[:name]
  #    site_hash[:source_type] #vol|mysql|pgsql|nosql|sys
  #    site_hash[:source_name]
  #    site_hash[:source_host]
  #    site_hash[:source_user]
  #    site_hash[:source_pass]
  #
  #    site_hash[:dest_proto]
  #    site_hash[:dest_port]
  #    site_hash[:dest_address]
  #    site_hash[:dest_folder]
  #    site_hash[:dest_user]
  #    site_hash[:dest_pass]
  #cmd= site_hash[:name] + " create "
  #  mkdir
  #  create conf
  #  add pre and post if needed

  def is_startup_complete container
    clear_error
    begin
      runDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName + "/run/"
      if File.exists?(runDir + "startup_complete")
        return true
      else
        return false
      end
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def set_engine_hostname_details(container,params)
    clear_error
    begin
      engine_name = params[:engine_name]
      hostname = params[:host_name]
      domain_name = params[:domain_name]

      if container.hostName != hostname || container.domainName != domain_name
        saved_hostName = container.hostName
        saved_domainName =  container.domainName

        nginx_service =  EnginesOSapi.loadManagedService("nginx",self)
        nginx_service.remove_consumer(container)

        dns_service = EnginesOSapi.loadManagedService("dns",self)
        dns_service.remove_consumer(container)

        container.set_hostname_details(hostname,domain_name)

        dns_service.add_consumer(container)
        nginx_service.add_consumer(container)

        return true
      end
      #true if no change
      return true
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def save_system_preferences
    clear_error
    begin
      p :pdsf
      return true
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def load_system_preferences
    clear_error
    begin
      p :psdfsd
    rescue  Exception=>e
      log_error(e)
      return false
    end
  end

  def get_system_load_info
    clear_error
    ret_val = Hash.new

    begin
      loadavg_info = File.read("/proc/loadavg")
      values = loadavg_info.split(" ")
      ret_val[:one] = values[0]
      ret_val[:five] = values[1]
      ret_val[:fithteen] = values[2]
      run_idle = values[3].split("/")
      ret_val[:running] = run_idle[0]
      ret_val[:idle] = run_idle[1]

    rescue Exception=>e
      log_error(e)
      ret_val[:one] = -1
      ret_val[:five] = -1
      ret_val[:fithteen] = -1
      ret_val[:running] = -1
      ret_val[:idle] = -1
      return ret_val
    end
    return ret_val

  end

  def get_system_memory_info
    clear_error
    ret_val = Hash.new

    begin
      proc_mem_info_file = File.open("/proc/meminfo")
      proc_mem_info_file.each_line  do |line|
        values=line.split(" ")

        case values[0]
        when "MemTotal:"
          ret_val[:total] = values[1]
        when "MemFree:"
          ret_val[:free]= values[1]
        when "Buffers:"
          ret_val[:buffers]= values[1]
        when "Cached:"
          ret_val[:file_cache]= values[1]
        when "Active:"
          ret_val[:active]= values[1]
        when "Inactive:"
          ret_val[:inactive]= values[1]
        when "SwapTotal:"
          ret_val[:swap_total]= values[1]
        when "SwapFree:"
          ret_val[:swap_free] = values[1]
        end
      end

    rescue   Exception=>e
      log_error(e)
      ret_val[:total] = e.to_s
      ret_val[:free] = -1
      ret_val[:active] = -1
      ret_val[:inactive] = -1
      ret_val[:file_cache] = -1
      ret_val[:buffers] = -1
      ret_val[:swap_total] = -1
      ret_val[:swap_free] = -1

      return ret_val
    end
    return ret_val

  end

  def get_container_memory_stats(container)
    clear_error
    ret_val= Hash.new
    begin
      if container && container.container_id == nil || container.container_id == '-1'
        container_id = read_container_id(container.containerName)
        container.container_id = container_id
      end
      if container && container.container_id != nil && container.container_id != '-1'
        path = "/sys/fs/cgroup/memory/docker/" + container.container_id
        if Dir.exists?(path)
          ret_val.store(:maximum , File.read(path + "/memory.max_usage_in_bytes"))
          ret_val.store(:current , File.read(path + "/memory.usage_in_bytes"))
          ret_val.store(:limit , File.read(path + "/memory.limit_in_bytes"))
        else
          ret_val.store(:maximum ,  "No Container")
          ret_val.store(:current , "No Container")
          ret_val.store(:limit ,  "No Container")
        end
      end

      return ret_val
    rescue  Exception=>e
      log_error(e)
      ret_val.store(:maximum ,  e.to_s)
      ret_val.store(:current , "NA")
      ret_val.store(:limit ,  "NA")
      return ret_val
    end
  end

  def get_container_network_metrics(containerName) #FIXME Kludge
    ret_val = Hash.new
    clear_error
    begin
      cmd = "docker exec " + containerName + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 " " $6}'  2>&1"
      res= %x<#{cmd}>

      vals = res.split("bytes:")
      #  p :sdfdssssssssssss
      #  p vals[0]
      #  p vals[1]
      #  p :sdf
      ret_val[:in] = vals[1].chop
      ret_val[:out] = vals[2].chop
    rescue Exception=>e
      log_error(e)
      ret_val[:in] = -1
      ret_val[:out] = -1
      return ret_val
    end
    return ret_val
  end

  protected

  def clear_error
    @last_error = ""
  end
  
  def log_error(e)
    @last_error = e.to_s
    p e
  end
  
  def container_state_dir container
    return SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
  end

  def container_log_dir container
   
    return SysConfig.SystemLogRoot + "/"  + container.ctype + "s/" + container.containerName
  end

  def get_volbuild_volmaps container
    clear_error
    state_dir = SysConfig.CidDir + "/containers/" + container.containerName + "/run/"
    log_dir = SysConfig.SystemLogRoot + "/containers/" + container.containerName
    volume_option = " -v " + state_dir + ":/client/state:rw "
    volume_option += " -v " + log_dir + ":/client/log:rw "
    if container.volumes != nil

      container.volumes.each do |vol|
        p vol
        volume_option += " -v " + vol.localpath.to_s + ":/dest/fs:rw"
      end
    end

    volume_option += " --volumes-from " + container.containerName

    return volume_option
  end

  def get_volume_option container
    clear_error
    #System
    volume_option = SysConfig.timeZone_fileMapping #latter this will be customised
    volume_option += " -v " + container_state_dir(container) + "/run/:/engines/var/run:rw "
    # if container.ctype == "service"
    #  volume_option += " -v " + container_log_dir(container) + ":/var/log:rw "
    incontainer_logdir = get_container_logdir(container)
    volume_option += " -v " + container_log_dir(container) + ":/" + incontainer_logdir + ":rw "
    if incontainer_logdir !="/var/log" && incontainer_logdir !="/var/log/"
      volume_option += " -v " + container_log_dir(container) + "/vlog:/var/log/:rw"
    end
    #end

    #container specific
    if(container.volumes)
      container.volumes.each do |volume|
        if volume !=nil
          if volume.name == nil
            volume_name = ""
          else
            volume_name = volume.name
          end

          if volume.localpath !=nil
            volume_option = volume_option.to_s + " -v " + volume.localpath.to_s + ":/" + volume.remotepath.to_s +  ":" + volume.mapping_permissions.to_s
          end
        end
      end
    end
    return volume_option
  end

  def clear_container_var_run(container)
    clear_error
    begin
    dir = container_state_dir(container)
    # Dir.unlink Will do but for moment
    #Dir.mkdir
    if File.exists?(dir + "/startup_complete")
      File.unlink(dir + "/startup_complete")
    end
    return true
    
    rescue Exception=>e
      log_error(e)
      return false
    end
  end

  def get_container_logdir container
    clear_error
    if container.framework == nil || container.framework.length ==0
      return "/var/log"
    end

    container_logdetails_file_name = false

    framework_logdetails_file_name =  SysConfig.DeploymentTemplates + "/" + container.framework + "/home/LOG_DIR"
    p framework_logdetails_file_name
    if File.exists?(framework_logdetails_file_name )
      container_logdetails_file_name = framework_logdetails_file_name
    else
      container_logdetails_file_name = SysConfig.DeploymentTemplates + "/global/home/LOG_DIR"
    end
    p     container_logdetails_file_name
    begin
      container_logdetails = File.read(container_logdetails_file_name)
    rescue
      container_logdetails = "/var/log"
    end

    return container_logdetails
  end

  def restart_nginx_process
    begin
      clear_error
    cmd= "docker exec nginx ps ax |grep \"nginx: master\" |grep -v grep |awk '{ print $1}'"

    p cmd
    nginxpid= %x<#{cmd}>
    p  nginxpid
    #FIXME read from pid file this is just silly
    docker_cmd = "docker exec nginx kill -HUP " + nginxpid.to_s
    p docker_cmd
    if nginxpid.to_s != "-"
      return run_system(docker_cmd)
    else
      return false
    end
    rescue Exception=>e
      log_error(e)
      return false
    end
  end

end