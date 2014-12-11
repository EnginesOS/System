require 'socket'
require 'json';

require 'open-uri';

module DNSHosting
  def DNSHosting.add_hosted_domain(params,core_api)
    domain= params[:domain_name]
    if(params[:internal_only])
      ip = IPSocket.getaddress(Socket.gethostname)
    else
      ip =  open( 'http://jsonip.com/ ' ){ |s| JSON::parse( s.string())['ip'] };
    end

    if DNSHosting.write_zone_file(domain,ip) == false
      DNSHosting.rm_local_domain_files domain
      return false
    end

    if DNSHosting.write_config(domain) == false
      DNSHosting.rm_local_domain_files domain
      return false
    end
    
    core_api.reload_dns

    return true
  rescue Exception=>e
    SystemUtils.log_exception(e)
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
    SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.write_config(domain)
    conf_file = File.open(SysConfig.DNSConfDir + "/" + domain,"w")
    conf_file.puts( "zone \"" + domain +"\" {")
    conf_file.puts("type master;")
    conf_file.puts("file \"" + File.read(SysConfig.DNSZoneDir + "/" + domain) + "\";")
    conf_file.puts("};")
    conf_file.close
    return true
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.rm_local_domain_files domain_name
    ret_val=false

    dns_zone_filename = SysConfig.DNSZoneDir + "/" + domain_name
    if File.exists?(dns_zone_filename)
      File.delete(dns_zone_filename)
      ret_val=true
    end

    dns_conf_filename = SysConfig.DNSConfDir + "/" + domain_name
    if File.exists?(dns_conf_filename)
      File.delete(dns_conf_filename)
      if ret_val == true # Need to carry first failure even if we delete this file
        ret_val=true
      end
    end

    return ret_val
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end

  def DNSHosting.rm_hosted_domain(params,core_api)
    domain= params[:domain_name]
    DNSHosting.rm_local_domain_files domain
    core_api.reload_dns
  end

end