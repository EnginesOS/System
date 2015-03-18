require 'socket'
require 'json';
require 'open-uri';

require '/opt/engines/lib/ruby/system/SystemUtils.rb'

module DNSHosting
  def DNSHosting.add_hosted_domain(params,system_api)
    domain= params[:domain_name]
    if(params[:internal_only])
      ip = DNSHosting.get_local_ip
    else
      ip =  open( 'http://jsonip.com/ ' ){ |s| JSON::parse( s.string())['ip'] };
    end

    if DNSHosting.write_zone_file(domain,ip) == false
      DNSHosting.rm_local_domain_files domain
      return false
    end
    
    domains = load_self_hosted_domains()
    domains[params[:domain_name]] = params 
    if DNSHosting.save_self_hosted_domains(domains)
      p :REloading_dns
      return system_api.reload_dns
    end

    p :failed_save_hosted_domains
    return false
    
  rescue Exception=>e
  SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.write_domain_list
        
    system_api.reload_dns

  end
  def DNSHosting.get_local_ip
    #case of management app in container
    if File.exists?("/opt/engines/.ip")
      ip = File.read("/opt/engines/.ip")
      return ip
    end
      #devel/lachlan case
    Socket.ip_address_list.each do |addr|
      if addr.ipv4?
        if addr.ipv4_loopback? == false
          return addr.ip_address
        end
      end
    end
    rescue Exception=>e
       SystemUtils. SystemUtils.log_exception(e)
       return false
  end
   
  
  def DNSHosting.write_zone_file(domain,ip)
    dns_template = File.read(SysConfig.SelfHostedDNStemplate)

    dns_template.gsub!("IP",ip)
    dns_template.gsub!("DOMAIN",domain)

    dns_file = File.open(SysConfig.DNSZoneDir + "/" + domain,"w")
    dns_file.write(dns_template)
    dns_file.close
    return true
  rescue Exception=>e
    SystemUtils. SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.write_config(domain,conf_file)
   
    conf_file.puts( "zone \"" + domain +"\" {")
    conf_file.puts("type master;")
    conf_file.puts("file \"/etc/bind/engines/zones/" + domain + "\";") #FIXME and put /etc... in config
    conf_file.puts("};")
   
    return true
  rescue Exception=>e
    SystemUtils. SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.rm_local_domain_files domain_name
    ret_val=false
  
    dns_zone_filename = SysConfig.DNSZoneDir + "/" + domain_name
    if File.exists?(dns_zone_filename)
      File.delete(dns_zone_filename)
      ret_val=true
    end

    return ret_val
  rescue Exception=>e
    SystemUtils. SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.rm_hosted_domain(domain,system_api)
    ret_val=false
    DNSHosting.rm_local_domain_files domain
    domains = DNSHosting.load_self_hosted_domains
    if domains.has_key?(domain)
      domains.delete(domain)  
      DNSHosting.save_self_hosted_domains(domains) 
      system_api.reload_dns
      ret_val=true
          
    end
    return ret_val
     rescue Exception=>e
       SystemUtils. SystemUtils.log_exception(e)
       return false
  end
  
  def DNSHosting.load_self_hosted_domains
    begin
      if File.exists?(SysConfig.HostedDomainsFile) == false
        self_hosted_domain_file = File.open(SysConfig.HostedDomainsFile,"w")
        self_hosted_domain_file.close
        return Hash.new
      else
        self_hosted_domain_file = File.open(SysConfig.HostedDomainsFile,"r")
      end
      self_hosted_domains = YAML::load( self_hosted_domain_file )
      self_hosted_domain_file.close
      if self_hosted_domains == false
        return Hash.new
      end
      return self_hosted_domains
    rescue Exception=>e
      self_hosted_domains = Hash.new
       SystemUtils.log_exception(e)
      return self_hosted_domains
    end
  end
  
  def DNSHosting.save_self_hosted_domains(domains)
      begin
        self_hosted_domain_file = File.open(SysConfig.HostedDomainsFile,"w")
        self_hosted_domain_file.write(domains.to_yaml())
        self_hosted_domain_file.close
        conf_file = File.open(SysConfig.DNSHostedList,"w")
        p domains
        p :domains
        domains.each_key do |domain|          
          p :domain
          p domain
          DNSHosting.write_config(domain,conf_file)
        end
        conf_file.close
      
        return true
        
      rescue Exception=>e
         SystemUtils.log_exception(e)
        return false
      end
    end
   


    
    
end