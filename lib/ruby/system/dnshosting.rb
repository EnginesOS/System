require 'socket'
require 'yajl'
require 'open-uri'

# require '/opt/engines/lib/ruby/system/SystemUtils.rb'

module DNSHosting
  def self.get_local_ip
    if File.exist?('/opt/engines/etc/net/ip')
      return File.read('/opt/engines/etc/net/ip')
    end
    # devel/lachlan case
    Socket.ip_address_list.each do |addr|
      return addr.ip_address if addr.ipv4? && addr.ipv4_loopback? == false
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def self.save_domains(domains)
    domain_file = File.open(SystemConfig.DomainsFile, 'w')
    domain_file.write(domains.to_yaml)
    domain_file.close
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return false
  end

  def self.load_domains
    if File.exist?(SystemConfig.DomainsFile) == false
      domains_file = File.open(SystemConfig.DomainsFile, 'w')
      domains_file.close
      return {}
    else
      domains_file = File.open(SystemConfig.DomainsFile, 'r')
    end
    domains = YAML::load(domains_file)
    domains_file.close
    SystemDebug.debug(SystemDebug.system,:loading_domain_list, domains.to_s)
    return {} if domains == false
    return domains
  rescue StandardError => e
    domains = {}
    p 'failed_to_load_domains'
    SystemUtils.log_exception(e)
    return domains
  end

  def self.list_domains
    domains = DNSHosting.load_domains
    return domains
  rescue StandardError => e
    domains = {}
    p :error_listing_domains
    SystemUtils.log_exception(e)
    return domains
  end

  def self.add_domain(params)
    domains = load_domains
    domains[params[:domain_name]] = params
    return true if save_domains(domains)
    p :failed_add_hosted_domains
    return false
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def self.rm_domain(domain)
  #  domain = params
  #  domain = params[:domain_name] unless domain.is_a?(String)      
    domains = load_domains
    if domains.key?(domain)
      domains.delete(domain)
      save_domains(domains)
    else
      p :failed_to_find_domain
      p domain
      p 'in ' + domains.to_s
    end
  end

  def self.update_domain(old_domain_name, params)
    domains = load_domains
    domains.delete(old_domain_name)
    params.delete(:original_domain_name) if params.key?(:original_domain_name)
    domains[params[:domain_name]] = params
    save_domains(domains)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return false
  end
end
