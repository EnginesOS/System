class EnginesCore

  require "/opt/engines/lib/ruby/SystemUtils.rb"
  require "/opt/engines/lib/ruby/system/DNSHosting.rb"

  class SystemApi
    attr_reader :last_error
    def initialize(api)
      @engines_api = api
    end

    #    def
    #      @docker_api.update_self_hosted_domain( params)
    #    end

    def create_container(container)
      clear_error
      begin
        cid = read_container_id(container)
        container.container_id=(cid)
        if save_container(container)  == true
          return register_dns_and_site(container)
        else
          return false #save_container false
        end

      rescue Exception=>e
        container.last_error=("Failed To Create " + e.to_s)
        log_exception(e)

        return false
      end
    end

    def register_dns_and_site(container)
      if container.conf_register_dns == true
        if container.register_dns() == true
          if container.conf_register_site() == true
            if container.register_site == true
              return true
            else
              return false  #failed to register
            end
          end # if reg site
        else
          return false #reg dns failed
        end
      end #if reg dns
      return true
    end

    def reload_dns
      dns_pid = File.read(SysConfig.NamedPIDFile)
      p :kill_HUP_TO_DNS
      p dns_pid.to_s
      return @engines_api.signal_service_process(dns_pid.to_s,'HUP','dns')
    rescue  Exception=>e
      log_exception(e)
      return false
    end

    def restart_nginx_process
      begin
        clear_error
        cmd= "docker exec nginx ps ax |grep \"nginx: master\" |grep -v grep |awk '{ print $1}'"

        SystemUtils.debug_output(cmd)
        nginxpid= %x<#{cmd}>
        SystemUtils.debug_output(nginxpid)
        #FIXME read from pid file this is just silly
        docker_cmd = "docker exec nginx kill -HUP " + nginxpid.to_s
        SystemUtils.debug_output(docker_cmd)
        if nginxpid.to_s != "-"
          return run_system(docker_cmd)
        else
          return false
        end
      rescue Exception=>e
        log_exception(e)
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
        if File.exists?(runDir + "/startup_complete")
          return true
        else
          return false
        end
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def format_cron_line(cron_hash)
      cron_line = String.new
      cron_line_split = cron_hash[:cron_job].split(/[\s\t]{1,10}/)
      for n in 0..4
        cron_line +=  cron_line_split[n] + " "
      end
      cron_line +=" docker exec " +  cron_hash[:container_name] + " "
      n=5
      cnt = cron_line_split.count

      while n < cnt
        cron_line += " " + cron_line_split[n]
        n+=1
      end
      return     cron_line
    rescue Exception=>e

      log_exception(e)

      return false
    end

    def add_cron(cron_hash)
      begin

        cron_line = format_cron_line(cron_hash)
        cron_file = File.open(  SysConfig.CronDir + "/crontab","a+")
        cron_file.puts(cron_line)
        cron_file.close

        return reload_crontab

      rescue Exception=>e

        log_exception(e)
        return false
      end
    end

    def reload_crontab
      docker_cmd="docker exec cron crontab " + "/home/crontabs/crontab"
      return run_system(docker_cmd)
    rescue Exception=>e

      log_exception(e)

      return false
    end

    def rebuild_crontab(cron_service)
      cron_file = File.open(  SysConfig.CronDir + "/crontab","w")

      cron_service.consumers.each do |cron_entry|

        cron_line = format_cron_line(cron_entry[1])
        p :cron_line
        p cron_line
        cron_file.puts(cron_line)
      end
      cron_file.close
      return reload_crontab

    rescue Exception=>e

      log_exception(e)

      return false

    end

    def remove_containers_cron_list(containerName)
      cron_service =  @engines_api.loadManagedService("cron")
      p :remove_cron_for
      p containerName

      cron_service.consumers.each do |cron_job|
        if cron_job != nil
          p cron_job
          p :looking_at
          p cron_job[1][:container_name]
          if cron_job[1][:container_name] ==  containerName
            cron_service.remove_consumer(cron_job[1])
          end
        end
      end
    rescue Exception=>e

      log_exception(e)

      return false
    end

    def clear_cid_file container
      clear_error
      begin
        cidfile =  container_cid_file(container)
        if File.exists? cidfile
          File.delete cidfile
        end
        return true
      rescue Exception=>e
        container.last_error=("Failed To Create " + e.to_s)
        log_exception(e)

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
        log_exception(e)
        return "-1";
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
        container.last_error=( "Failed To Destroy " + e.to_s)
        log_exception(e)

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
        log_exception(e)
        return false
      end
    end

    def delete_container_configs(container)
      clear_error
      begin
        stateDir = container_state_dir(container) + "/config.yaml"
        File.delete(stateDir)
        return true
      rescue Exception=>e
        container.last_error=( "Failed To Delete " )
        log_exception(e)
        return false
      end
    end

    def deregister_dns(top_level_hostname)
      clear_error
      begin
        fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
        dns_cmd_file_name="/tmp/.top_level_hostname.dns_cmd_file"
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
        log_exception(e)
        return false
      end
    end

    def get_cert_name(fqdn)
      if File.exists?(SysConfig.NginxCertDir + "/" + fqdn + ".crt")
        return  fqdn
      else
        return SysConfig.NginxDefaultCert
      end
    end

    def register_site(site_hash)
      clear_error
      begin
        proto = site_hash[:proto]
        if proto =="http https"
          template_file=SysConfig.HttpHttpsNginxTemplate
        elsif proto =="http"
          template_file=SysConfig.HttpNginxTemplate
        elsif proto == "https"
          template_file=SysConfig.HttpsNginxTemplate
        elsif proto == nil
          p "Proto nil"
          template_file=SysConfig.HttpHttpsNginxTemplate
        else
          p "Proto" + proto + "  unknown"
          template_file=SysConfig.HttpHttpsNginxTemplate
        end

        file_contents=File.read(template_file)
        site_config_contents =  file_contents.sub("FQDN",site_hash[:fqdn])
        site_config_contents = site_config_contents.sub("PORT",site_hash[:port])
        site_config_contents = site_config_contents.sub("SERVER",site_hash[:name]) #Not HostName
        if proto =="https" || proto =="http https"
          site_config_contents = site_config_contents.sub("CERTNAME",get_cert_name(site_hash[:fqdn])) #Not HostName
          site_config_contents = site_config_contents.sub("CERTNAME",get_cert_name(site_hash[:fqdn])) #Not HostName
        end
        if proto =="http https"
          #Repeat for second entry
          site_config_contents =  site_config_contents.sub("FQDN",site_hash[:fqdn])
          site_config_contents = site_config_contents.sub("PORT",site_hash[:port])
          site_config_contents = site_config_contents.sub("SERVER",site_hash[:name]) #Not HostName
        end

        site_filename = get_site_file_name(site_hash)

        site_file  =  File.open(site_filename,'w')
        site_file.write(site_config_contents)
        site_file.close
        result = restart_nginx_process()
        return result
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def hash_to_site_str(site_hash)
      clear_error
      begin
        return site_hash[:name].to_s + ":" +  site_hash[:fqdn].to_s + ":" + site_hash[:port].to_s  + ":" + site_hash[:proto].to_s
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def get_site_file_name(site_hash)
      file_name = String.new
      proto = site_hash[:proto]
      p :proto
      p proto
      if proto == "http https"
        proto ="http_https"
      end
      file_name=SysConfig.NginxSiteDir + "/" + proto + "_" +  site_hash[:fqdn] + ".site"
      return file_name

    end

    def deregister_site(site_hash)
      clear_error
      begin
        #        #  ssh_cmd=SysConfig.rmSiteCmd +  " \"" + hash_to_site_str(site_hash) +  "\""
        #        #FIXME Should write site conf file via template (either standard or supplied with blueprint)
        #        ssh_cmd = "/opt/engines/scripts/nginx/rmsite.sh " + " \"" + hash_to_site_str(site_hash)   +  "\""
        #        SystemUtils.debug_output ssh_cmd
        #        result = run_system(ssh_cmd)
        site_filename = get_site_file_name(site_hash)
        if File.exists?(site_filename)
          File.delete(site_filename)
        end
        result = restart_nginx_process()
        return result
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def add_ftp_service(site_hash)
      clear_error
      begin
        SystemUtils.debug_output site_hash
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def rm_ftp_service(site_hash)
      clear_error
      begin
        SystemUtils.debug_output site_hash
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def add_monitor(site_hash)
      clear_error
      begin
        ssh_cmd=SysConfig.addSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
        return run_system(ssh_cmd)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def rm_monitor(site_hash)
      clear_error
      begin
        ssh_cmd=SysConfig.rmSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
        return run_system(ssh_cmd)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def save_container(container)
      clear_error
      begin
        serialized_object = YAML::dump(container)
        stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
        if File.directory?(stateDir) ==false
          Dir.mkdir(stateDir)
          Dir.mkdir(stateDir + "/run")
        end
        log_dir = container_log_dir(container)
        if File.directory?(log_dir) ==false
          Dir.mkdir(log_dir)
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
        container.last_error=( "load error")
        log_exception(e)
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
        statefile=stateDir + "/blueprint.json"
        f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
        f.write(blueprint.to_json)
        f.close
      rescue  Exception=>e
        log_exception(e)
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
        statefile=stateDir + "/blueprint.json"
        if File.exists?(statefile)
          f = File.new(statefile,"r")
          blueprint = JSON.parse( f.read())
          f.close
        else
          return false
        end
        return blueprint
      rescue  Exception=>e
        log_exception(e)
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
        log_exception(e)
        return false
      end
    end

    def rm_volume(site_hash)
      clear_error
      begin
        puts "would remove " + site_hash[:localpath]
        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def rm_backup(site_hash)
      clear_error
      begin
        ssh_cmd=SysConfig.rmBackupCmd + " " + site_hash[:name]
        return run_system(ssh_cmd)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def create_backup(site_hash)
      clear_error
      begin
        containerName = site_hash[:engine_name]
        SystemUtils.debug_output site_hash
        if site_hash[:source_type] =="fs"
          site_src=containerName + ":fs:" + site_hash[:source_name]
        else
          site_src=containerName + ":" + site_hash[:source_type] + ":" +  site_hash[:source_user] +":" +  site_hash[:source_pass] + "@" +  site_hash[:source_host] + "/" + site_hash[:source_name]
        end
        #FIXME
        site_dest=site_hash[:dest_proto] +":" + site_hash[:dest_user] + ":" + site_hash[:dest_pass] + "@" +  site_hash[:dest_address] + "/" + site_hash[:dest_folder]
        ssh_cmd=SysConfig.addBackupCmd + " " + site_hash[:name] + " " + site_src + " " + site_dest
        run_system(ssh_cmd)
        #FIXME shoudl return about result and not just true
        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def  save_domains(domains)
      clear_error
      begin
        domain_file = File.open(SysConfig.DomainsFile,"w")
        domain_file.write(domains.to_yaml())
        domain_file.close
        return true
      rescue Exception=>e
        SystemUtils.log_exception(e)
        return false
      end
    end

    def load_domains
      clear_error
      begin
        if File.exists?(SysConfig.DomainsFile) == false
          self_hosted_domain_file = File.open(SysConfig.DomainsFile,"w")
          self_hosted_domain_file.close
          return Hash.new
        else
          self_hosted_domain_file = File.open(SysConfig.DomainsFile,"r")
        end
        domains = YAML::load( self_hosted_domain_file )
        self_hosted_domain_file.close
        if domains == false
          return Hash.new
        end
        return domains
      rescue Exception=>e
        domains = Hash.new
        SystemUtils.log_exception(e)
        return domains
      end
    end

    def list_domains
      domains = load_domains
      return domains
    rescue Exception=>e
      domains = Hash.new
      SystemUtils.log_exception(e)
      return domains
    end

    def add_domain(params)
      clear_error
      domain= params[:domain_name]
      if params[:self_hosted]
        add_self_hosted_domain params
      end
      p :add_domain
      p params
      domains = load_domains()
      domains[params[:domain_name]] = params
      if save_domains(domains)
        return true
      end

      p :failed_add_hosted_domains
      return false

    rescue Exception=>e
      SystemUtils.log_exception(e)
      return false
    end

    def rm_domain(domain,system_api)
      clear_error
      domains = load_domains
      if domains.has_key?(domain)
        domains.delete(domain)
        save_domains(domains)
        system_api.reload_dns
      end

    end

    def  update_domain(old_domain_name, params,system_api)
      clear_error
      begin
        domains = load_domains()
        domains.delete(old_domain_name)
        domains[params[:domain_name]] = params
        save_domains(domains)

        if params[:self_hosted]
          add_self_hosted_domain params
          rm_self_hosted_domain(old_domain_name)
          system_api.reload_dns
        end

        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def add_self_hosted_domain params
      clear_error
      begin
        p :Lachlan_Sent_parrams
        p params

        return DNSHosting.add_hosted_domain(params,self)
        #       if ( DNSHosting.add_hosted_domain(params,self) == false)
        #         return false
        #       end
        #
        #     domains = load_self_hosted_domains()
        #       domains[params[:domain_name]] = params
        #
        return  save_self_hosted_domains(domains)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def list_self_hosted_domains()
      clear_error
      begin
        return DNSHosting.load_self_hosted_domains()
        #        domains = load_self_hosted_domains()
        #        p domains
        #        return domains
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def  update_self_hosted_domain(old_domain_name, params)
      clear_error
      begin
        domains = load_self_hosted_domains()
        domains.delete(old_domain_name)
        domains[params[:domain_name]] = params
        save_self_hosted_domains(domains)
        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def   remove_self_hosted_domain( domain_name)
      clear_error
      begin
        return DNSHosting.rm_hosted_domain(domain_name,self)
        #        domains = load_self_hosted_domains()
        #        domains.delete(domain_name)
        #        save_self_hosted_domains(domains)
        #        return true
      rescue  Exception=>e
        log_exception(e)
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

    def save_system_preferences
      clear_error
      begin
        SystemUtils.debug_output :pdsf
        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def load_system_preferences
      clear_error
      begin
        SystemUtils.debug_output :psdfsd
      rescue  Exception=>e
        log_exception(e)
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
          path = "/sys/fs/cgroup/memory/docker/" + container.container_id + "/"
          if Dir.exists?(path)
            ret_val.store(:maximum , File.read(path + "/memory.max_usage_in_bytes"))
            ret_val.store(:current , File.read(path + "/memory.usage_in_bytes"))
            ret_val.store(:limit , File.read(path + "/memory.limit_in_bytes"))
          else
            p :no_cgroup_file
            p path
            ret_val.store(:maximum ,  "No Container")
            ret_val.store(:current , "No Container")
            ret_val.store(:limit ,  "No Container")
          end
        end

        return ret_val
      rescue  Exception=>e
        log_exception(e)
        ret_val.store(:maximum ,  e.to_s)
        ret_val.store(:current , "NA")
        ret_val.store(:limit ,  "NA")
        return ret_val
      end
    end

    def set_engine_network_properties(engine, params)
      clear_error
      begin
        engine_name = params[:engine_name]
        protocol = params[:http_protocol]
        if protocol.nil?
          p params
          return false
        end

        SystemUtils.debug_output("Changing protocol to _" + protocol + "_")
        if protocol.include?("HTTPS only")
          engine.enable_https_only
        elsif protocol.include?("HTTP only")
          engine.enable_http_only
        elsif protocol.include?("HTTPS and HTTP")
          engine.enable_http_and_https
        end

        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def set_engine_hostname_details(container,params)
      clear_error
      begin
        engine_name = params[:engine_name]
        hostname = params[:host_name]
        domain_name = params[:domain_name]

        SystemUtils.debug_output("Changing Domainame to " + domain_name)

        if container.hostName != hostname || container.domainName != domain_name
          saved_hostName = container.hostName
          saved_domainName =  container.domainName
          SystemUtils.debug_output("Changing Domainame to " + domain_name)

          if container.set_hostname_details(hostname,domain_name) == true
            nginx_service =  EnginesOSapi.loadManagedService("nginx",self)
            nginx_service.remove_consumer(container)

            dns_service = EnginesOSapi.loadManagedService("dns",self)
            dns_service.remove_consumer(container)

            dns_service.add_consumer(container)
            nginx_service.add_consumer(container)
            save_container(container)
          end

          return true
        end
        return true
      rescue  Exception=>e
        log_exception(e)
        return false
      end
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
        return ret_val
      rescue   Exception=>e
        log_exception(e)
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
        log_exception(e)
        ret_val[:one] = -1
        ret_val[:five] = -1
        ret_val[:fithteen] = -1
        ret_val[:running] = -1
        ret_val[:idle] = -1
        return ret_val

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def getManagedEngines()
      begin
        ret_val=Array.new
        Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
          yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"
          if File.exists?(yfn) == true
            managed_engine = loadManagedEngine(contdir)
            if managed_engine.is_a?(ManagedEngine)
              ret_val.push(managed_engine)
            else
              log_error("failed to load " + yfn)
            end
          end
        end
        return ret_val
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def loadManagedEngine(engine_name)
      if engine_name == nil || engine_name.length ==0
        last_error="No Engine Name"
        return false
      end
      begin
        yam_file_name = SysConfig.CidDir + "/containers/" + engine_name + "/config.yaml"

        if File.exists?(yam_file_name) == false
          log_error("no such file " + yam_file_name )
          return false # return failed(yam_file_name,"No such configuration:","Load Engine")
        end

        yaml_file = File.open(yam_file_name)
        managed_engine = ManagedEngine.from_yaml( yaml_file,@engines_api)

        if(managed_engine == nil || managed_engine == false)
          p :from_yaml_returned_nil
          return false # failed(yam_file_name,"Failed to Load configuration:","Load Engine")
        end
        return managed_engine

      rescue Exception=>e
        if engine_name != nil
          if managed_engine !=nil
            managed_engine.last_error=( "Failed To get Managed Engine " +  engine_name + " " + e.to_s)
            log_error(managed_engine.last_error)
          end
        else
          log_error("nil Engine Name")
        end
        log_exception(e)
        return false
      end
    end

    def loadManagedService(service_name)
      begin
        if service_name == nil || service_name.length ==0
          last_error="No Service Name"
          return false
        end
        yam_file_name = SysConfig.CidDir + "/services/" + service_name + "/config.yaml"

        if File.exists?(yam_file_name) == false
          return false # return failed(yam_file_name,"No such configuration:","Load Service")
        end

        yaml_file = File.open(yam_file_name)
        # managed_service = YAML::load( yaml_file)
        managed_service = ManagedService.from_yaml(yaml_file,@engines_api)
        if managed_service == nil
          return false # return EnginsOSapiResult.failed(yam_file_name,"Fail to Load configuration:","Load Service")
        end

        return managed_service
      rescue Exception=>e
        if service_name != nil
          if managed_service !=nil
            managed_service.last_error=( "Failed To get Managed Engine " +  service_name + " " + e.to_s)
            log_error(managed_service.last_error)
          end
        else
          log_error("nil Service Name")
        end
        log_exception(e)
        return false
      end
    end

    def getManagedServices()
      begin
        ret_val=Array.new
        Dir.entries(SysConfig.CidDir + "/services/").each do |contdir|
          yfn = SysConfig.CidDir + "/services/" + contdir + "/config.yaml"
          if File.exists?(yfn) == true
            yf = File.open(yfn)
            managed_service = ManagedService.from_yaml(yf,@engines_api)
            if managed_service
              ret_val.push(managed_service)
            end
            yf.close
          end
        end
        return ret_val
      rescue Exception=>e
        log_exception(e)
        return false
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
        log_exception(e)
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
        log_exception(e)
        return ret_val
      end
      return ret_val
    end

    def clear_container_var_run(container)
      clear_error
      begin
        dir = container_state_dir(container)
        #
        #remove startup only
        #latter have function to reset subs and other flags

        if File.exists?(dir + "/startup_complete")
          File.unlink(dir + "/startup_complete")
        end
        return true

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    protected

    def container_cid_file(container)
      return  SysConfig.CidDir + "/"  + container.containerName + ".cid"
    end

    def container_state_dir(container)
      return SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
    end

    def container_log_dir container
      return SysConfig.SystemLogRoot + "/"  + container.ctype + "s/" + container.containerName
    end

    def run_system (cmd)
      clear_error
      begin
        cmd = cmd + " 2>&1"
        res= %x<#{cmd}>
        SystemUtils.debug_output res
        #FIXME should be case insensitive The last one is a pure kludge
        #really need to get stderr and stdout separately
        if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
          return true
        else
          return res
        end
      rescue Exception=>e
        log_exception(e)
        return ret_val
      end
    end

    def clear_error
      @last_error = ""
    end

    def  log_error(e_str)
      @last_error = e_str
      SystemUtils.log_output(e_str,10)
    end

    def log_exception(e)
      e_str = e.to_s()
      e.backtrace.each do |bt |
        e_str += bt
      end
      log_error(e_str)
    end

  end #END of SystemApi

  class DockerApi
    attr_reader :last_error
    def create_container container
      clear_error
      begin
        commandargs = container_commandline_args(container)
        commandargs = " run  -d " + commandargs
        SystemUtils.debug_output commandargs
        retval = run_docker(commandargs,container)
        return retval
      rescue Exception=>e
        container.last_error=("Failed To Create ")
        log_exception(e)
        return false
      end
    end

    def start_container   container
      clear_error
      begin
        commandargs =" start " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def stop_container container
      clear_error
      begin
        commandargs=" stop " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def pause_container container
      clear_error
      begin
        commandargs = " pause " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def unpause_container container
      clear_error
      begin
        commandargs=" unpause " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def ps_container container
      clear_error
      begin
        commandargs=" top " + container.containerName + " axl"
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def signal_container_process(pid,signal,container)
      clear_error
      commandargs=" exec " + container.containerName + " kill -" + signal + " " + pid.to_s
      return  run_docker(commandargs,container)
    rescue  Exception=>e
      log_exception(e)
      return false
    end

    def logs_container container
      clear_error
      begin
        commandargs=" logs " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def inspect_container container
      clear_error
      begin
        commandargs=" inspect " + container.containerName
        return  run_docker(commandargs,container)
      rescue  Exception=>e
        log_exception(e)
        return false
      end
    end

    def destroy_container container
      clear_error
      begin
        commandargs= " rm " +   container.containerName
        ret_val = run_docker(commandargs,container)
      rescue Exception=>e
        container.last_error=( "Failed To Destroy " + e.to_s)
        log_exception(e)

        return false
      end
    end

    def delete_image container
      clear_error
      begin
        commandargs= " rmi " +   container.image
        ret_val =  run_docker(commandargs,container)
        return ret_val
      rescue Exception=>e
        container.last_error=( "Failed To Delete " + e.to_s)
        log_exception(e)
        return false
      end
    end

    def run_docker (args,container)
      clear_error
      require 'open3'
      SystemUtils.debug_output(args)
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
              #              p :lne_by_line
              #              p line
              if stderr_is_open
                error_mesg += stderr.read_nonblock(256)
              end
            }
          rescue Errno::EIO
            res += oline.chop
            SystemUtils.debug_output(oline)
            error_mesg += stderr.read_nonblock(256)
          rescue  IO::WaitReadable
            retry
          rescue EOFError
            if stdout.closed? == false
              stderr_is_open = false
              retry
            elsif stderr.closed? == false
              error_mesg += stderr.read_nonblock(1000)
              container.last_result=(  res)
              container.last_error=( error_mesgs)
            else
              container.last_result=(  res)
              container.last_error=( error_mesgs)
            end
          end
          @last_error=error_mesg
          if error_mesg.include?("Error")
            container.last_error=(error_mesg)

            return false
          else
            container.last_error=("")
          end
          #
          #          if res.start_with?("[") == true
          #            res = res +"]"
          #          end
          if res.end_with?(']') == false
            res+=']'
          end

          container.last_result=(res)
          return true
        end
      rescue Exception=>e
        @last_error=error_mesg + e.to_s
        container.last_result=(res)
        container.last_error=(error_mesg + e.to_s)
        log_exception(e)
        return false
      end

      return true
    end

    def get_envionment_options(container)
      e_option =String.new
      if(container.environments)
        container.environments.each do |environment|
          if environment != nil
            e_option = e_option + " -e " + environment.name + "=" + '"' + environment.value + '"'
          end
        end
      end
      return e_option
    rescue Exception=>e
      log_exception(e)
      return e.to_s
    end

    def get_port_options(container)
      eportoption = String.new
      if(container.eports )
        container.eports.each do |eport|
          if eport != nil
            eportoption = eportoption +  " -p "
            if eport.external >0
              eportoption = eportoption + eport.external.to_s + ":"
            end
            eportoption = eportoption + eport.port.to_s
            if eport.proto_type == nil
              eport.proto_type=('tcp')
            end
            eportoption = eportoption + "/"+ eport.proto_type + " "
          end
        end
      end
      return eportoption
    rescue Exception=>e
      log_exception(e)
      return e.to_s
    end

    def container_commandline_args(container)
      clear_error
      begin
        envionment_options = get_envionment_options( container)
        port_options = get_port_options( container)
        volume_option = get_volume_option( container)
        if container.conf_self_start == false
          start_cmd=" /bin/bash /home/init.sh"
        else
          start_cmd=" "
        end
        commandargs =  "-h " + container.hostName + \
        envionment_options + \
        " --memory=" + container.memory.to_s + "m " +\
        volume_option + " " +\
        port_options +\
        " --cidfile " + SysConfig.CidDir + "/" + container.containerName + ".cid " +\
        "--name " + container.containerName + \
        "  -t " + container.image + " " +\
        start_cmd

        return commandargs
      rescue Exception=>e
        log_exception(e)
        return e.to_s
      end
    end

    def get_volume_option(container)
      clear_error
      begin
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
          container.volumes.each_value do |volume|
            if volume !=nil
              if volume.localpath !=nil
                volume_option = volume_option.to_s + " -v " + volume.localpath.to_s + ":/" + volume.remotepath.to_s +  ":" + volume.mapping_permissions.to_s
              end
            end
          end
        end
        return volume_option
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def get_container_logdir(container)
      clear_error
      if container.framework == nil || container.framework.length ==0
        return "/var/log"
      end

      container_logdetails_file_name = false

      framework_logdetails_file_name =  SysConfig.DeploymentTemplates + "/" + container.framework + "/home/LOG_DIR"
      SystemUtils.debug_output(framework_logdetails_file_name)

      if File.exists?(framework_logdetails_file_name )
        container_logdetails_file_name = framework_logdetails_file_name
      else
        container_logdetails_file_name = SysConfig.DeploymentTemplates + "/global/home/LOG_DIR"
      end
      SystemUtils.debug_output(container_logdetails_file_name)
      begin
        container_logdetails = File.read(container_logdetails_file_name)
      rescue
        container_logdetails = "/var/log"
      end

      return container_logdetails
    rescue Exception=>e
      log_exception(e)

      return false
    end

    protected

    def container_state_dir(container)
      return SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
    end

    def container_log_dir container
      return SysConfig.SystemLogRoot + "/"  + container.ctype + "s/" + container.containerName
    end

    def clear_error
      @last_error = ""
    end

    def log_exception(e)
      e_str = e.to_s()
      n=0
      e.backtrace.each do |bt |
        e_str += bt
        if n >10
          break
        end
        ++n
      end
      @last_error = e_str
      SystemUtils.log_output(e_str,10)

    end
  end#END of DockerApi

  def initialize
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  #will change to to docker_api and not self
  end

  attr_reader :last_error

  def add_share(site_hash)
  end

  def rm_share(site_hash)
  end

  def add_domain(params)
    return  @system_api.add_domain(params)
  end

  def add_cron(cron_hash)
    p :add_cront
    return  @system_api.add_cron(cron_hash)
  end

  def remove_containers_cron_list(containerName)
    p :remove_containers_cron
    if @system_api.remove_containers_cron_list(containerName)
      cron_service = loadManagedService("cron")
      return @system_api.rebuild_crontab(cron_service)
    else
      return false
    end
  end

  def rebuild_crontab(cron_service)
    #acutally a rebuild (or resave) as hadh already removed from consumer list
    p :rebuild_crontab
    return  @system_api.rebuild_crontab(cron_service)
  end

  def remove_domain(params)
    return @system_api.rm_domain(params[:domain_name],@system_api)
  end

  def update_domain(old_domain,params)
    return @system_api.update_domain(old_domain,params,@system_api)
  end

  def signal_service_process(pid,sig,name)
    container = loadManagedService(name)
    return @docker_api.signal_container_process(pid,sig,container)
  end

  def start_container(container)
    if @docker_api.start_container(container) == true
      return true
    end
    return false
  end

  def inspect_container(container)
    return  @docker_api.inspect_container(container)
  end

  def stop_container(container)
    if @docker_api.stop_container(container) == true
      return  true
    end
    return false
  end

  def pause_container(container)
    return  @docker_api.pause_container(container)
  end

  def  unpause_container(container)
    return  @docker_api.unpause_container(container)
  end

  def  ps_container(container)
    return  @docker_api.ps_container(container)
  end

  def  logs_container(container)
    return  @docker_api.logs_container(container)
  end

  def add_ftp_service(site_hash)
    return @system_api.add_ftp_service(site_hash)
  end

  def rm_ftp_service(site_hash)
    return @system_api.rm_ftp_service(site_hash)
  end

  def add_monitor(site_hash)
    return @system_api.add_monitor(site_hash)
  end

  def rm_monitor(site_hash)
    return @system_api.rm_monitor(site_hash)
  end

  def save_container(container)
    return @system_api.save_container(container)
  end

  def save_blueprint(blueprint,container)
    return @system_api.save_blueprint(blueprint,container)
  end

  def load_blueprint(container)
    return @system_api.load_blueprint(container)
  end

  def add_volume(site_hash)
    return @system_api.add_volume(site_hash)
  end

  def rm_volume(site_hash)
    return @system_api.rm_volume(site_hash)
  end

  def create_backup(site_hash)
    return @system_api.create_backup(site_hash)
  end

  def remove_self_hosted_domain(domain_name)
    return @system_api.remove_self_hosted_domain(domain_name)
  end

  def add_self_hosted_domain(params)
    return @system_api.add_self_hosted_domain(params)
  end

  def list_self_hosted_domains()
    return @system_api.list_self_hosted_domains()
  end

  def  update_self_hosted_domain(old_domain_name, params)
    @system_api.update_self_hosted_domain(old_domain_name, params)
  end

  def load_system_preferences
    return @system_api.load_system_preferences
  end

  def save_system_preferences
    return @system_api.save_system_preferences
  end

  def register_site(site_hash)
    return @system_api.register_site(site_hash)
  end

  def deregister_site(site_hash)
    return @system_api.deregister_site(site_hash)
  end

  def hash_to_site_str(site_hash)
    return @system_api.hash_to_site_str(site_hash)
  end

  def  deregister_dns(top_level_hostname)
    return @system_api.deregister_dns(top_level_hostname)
  end

  def register_dns(top_level_hostname,ip_addr_str)
    return @system_api.register_dns(top_level_hostname,ip_addr_str)
  end

  def get_container_memory_stats(container)
    return @system_api.get_container_memory_stats(container)
  end

  def set_engine_hostname_details(container,params)
    return @system_api.set_engine_hostname_details(container,params)
  end

  def list_avail_services_for(object)
    objectname = object.class.name.split('::').last
    services = load_avail_services_for(objectname)
    subservices = load_avail_component_services_for(object)

    retval = Hash.new
    retval[:services] = services
    retval[:components] = subservices
    return retval
  end

  def load_service_definition(filename)
    yaml_file = File.open(filename)
   return  SoftwareServiceDefinition.from_yaml(yaml_file)
   
  end
  
  def load_avail_services_for(objectname)
    retval = Array.new

    dir = SysConfig.ServiceTemplateDir + "/" + objectname
    if Dir.exists?(dir)
    Dir.foreach(dir) do |service_dir_entry|
      p :service_dir_entry
      p service_dir_entry
      if service_dir_entry.endsWith(".yaml")
        service = load_service_definition(service_dir_entry)
        if service != nil
          p :service
          p service
          retval.push(service)
        end
      end
     end
    end
    return retval
  end

  def load_avail_component_services_for(object)
  retval = Hash.new
    if object.is_a?(ManagedEngine)
      if object.Volumes.count >0
        volumes = load_avail_services_for("Volume") #Array of hashes
        retval[:volumes] = volumes                    
      end
      if object.databases.count >0
        databases = load_avail_services_for("Database") #Array of hashes
        retval[:databases] = databases
      end

      return retval
    else
      return nil
    end
  end

  def set_engine_runtime_properties(params)
    #FIX ME also need to deal with Env Variables
    engine_name = params[:engine_name]

    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult) == false
      last_error = engine.result_mesg
      return false
    else
      if params.has_key?(:memory)
        if engine.update_memory(memory) == false
          last_error= engine.last_error
          return false
        end
      end
      if engine.is_active == true
        last_error="Container is active"
        return false
      end

      if engine.has_container? == true
        if destroy_container(engine)  == false
          last_error= engine.last_error
          return false
        end
      end

      if  create_container(engine) == false
        last_error= engine.last_error
        return false
      end
      return true
    end
  end

  def set_engine_network_properties (engine, params)
    return @system_api.set_engine_network_properties(engine,params)
  end

  def get_system_load_info
    return @system_api.get_system_load_info
  end

  def get_system_memory_info
    return @system_api.get_system_memory_info
  end

  def getManagedEngines
    return @system_api.getManagedEngines
  end

  def loadManagedEngine(engine_name)
    return @system_api.loadManagedEngine(engine_name)
  end

  def loadManagedService(service_name)
    return @system_api.loadManagedService(service_name)
  end

  def getManagedServices
    return @system_api.getManagedServices
  end

  def list_domains
    return @system_api.list_domains
  end

  def list_managed_engines
    return @system_api.list_managed_engines
  end

  def list_managed_services
    return @system_api.list_managed_services
  end

  def destroy_container(container)
    clear_error
    begin
      if @docker_api.destroy_container(container) != false
        container.deregister_registered
        @system_api.destroy_container(container)  #removes cid file
        return true
      else
        return false
      end
    rescue Exception=>e
      container.last_error=( "Failed To Destroy " + e.to_s)
      log_exception(e)

      return false
    end
  end

  def create_database  site_hash
    clear_error
    begin
      container_name =  site_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/createdb.sh " + site_hash[:name] + " " + site_hash[:user] + " " + site_hash[:pass]
      SystemUtils.debug_output(cmd)

      return run_system(cmd)
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end

  def delete_image(container)
    begin
      clear_error

      if @docker_api.delete_image(container) == true
        res = @system_api.delete_container_configs(container)
        return res
      else
        return false
      end

    rescue Exception=>e
      container.last_error=( "Failed To Delete " + e.to_s)
      log_exception(e)
      return false

    end
  end

  def run_system(cmd)
    clear_error
    begin
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>
      SystemUtils.debug_output res
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
        return true
      else
        @last_error = res
        SystemUtils.debug_output res
        return false
      end
    rescue Exception=>e
      log_exception(e)
      return ret_val
    end
  end

  def run_volume_builder(container,username)
    clear_error
    begin
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        command = "docker stop volbuilder"
        run_system(command)
        command = "docker rm volbuilder"
        run_system(command)
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      mapped_vols = get_volbuild_volmaps container
      command = "docker run --name volbuilder --memory=20m -e fw_user=" + username + " --cidfile /opt/engines/run/volbuilder.cid " + mapped_vols + " -t engines/volbuilder /bin/sh /home/setup_vols.sh "
      SystemUtils.debug_output command
      run_system(command)
      command = "docker stop volbuilder;  docker rm volbuilder"
      if File.exists?(SysConfig.CidDir + "/volbuilder.cid") == true
        File.delete(SysConfig.CidDir + "/volbuilder.cid")
      end
      res = run_system(command)
      if  res != true
        log_error(res)
        return false
      end
      return true
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_container(container)
    clear_error
    begin
      if @system_api.clear_cid(container) != false
        @system_api.clear_container_var_run(container)
        if  @docker_api.create_container(container) == true
          return @system_api.create_container(container)
        end
      else
        return false
      end
    rescue Exception=>e
      container.last_error=("Failed To Create " + e.to_s)
      log_exception(e)

      return false
    end
  end

  def rebuild_image(container)
    clear_error
    begin
      params=Hash.new
      params[:engine_name] = container.containerName
      params[:domain_name] = container.domainName
      params[:host_name] = container.hostName
      params[:env_variables] = container.environments
      params[:http_protocol] = container.protocol
      params[:repository]  = container.repo
      builder = EngineBuilder.new(params, self)
      return  builder.rebuild_managed_container(container)
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end

  #FIXME Kludge
  def get_container_network_metrics(containerName)
    begin
      ret_val = Hash.new
      clear_error
      cmd = "docker exec " + containerName + " netstat  --interfaces -e |  grep bytes |head -1 | awk '{ print $2 " " $6}'  2>&1"
      res= %x<#{cmd}>
      vals = res.split("bytes:")
      ret_val[:in] = vals[1].chop
      ret_val[:out] = vals[2].chop
      return ret_val
    rescue Exception=>e
      log_exception(e)
      ret_val[:in] = -1
      ret_val[:out] = -1
      return ret_val
    end
  end

  def is_startup_complete container
    clear_error
    begin
      return @system_api.is_startup_complete(container)
    rescue  Exception=>e
      log_exception(e)
      return false
    end
  end

  protected

  def get_volbuild_volmaps container
    begin
      clear_error
      state_dir = SysConfig.CidDir + "/containers/" + container.containerName + "/run/"
      log_dir = SysConfig.SystemLogRoot + "/containers/" + container.containerName
      volume_option = " -v " + state_dir + ":/client/state:rw "
      volume_option += " -v " + log_dir + ":/client/log:rw "
      if container.volumes != nil
        container.volumes.each_value do |vol|
          SystemUtils.debug_output vol
          volume_option += " -v " + vol.localpath.to_s + ":/dest/fs:rw"
        end
      end
      volume_option += " --volumes-from " + container.containerName
      return volume_option
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clear_error
    @last_error = ""
  end

  def log_exception(e)
    e_str = e.to_s()
    e.backtrace.each do |bt |
      e_str += bt
    end
    @last_error = e_str
    SystemUtils.log_output(e_str,10)
  end

end

