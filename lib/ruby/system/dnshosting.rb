require 'socket'

#require 'yajl'
require 'open-uri'

# require '/opt/engines/lib/ruby/system/SystemUtils.rb'

module DNSHosting
  def self.get_local_ip
    if File.exist?('/opt/engines/etc/exported/net/exported/ip')
      File.read('/opt/engines/etc/exported/net/exported/ip').strip
    else
      # devel/lachlan case
      Socket.ip_address_list.each do |addr|
        return addr.ip_address if addr.ipv4? && addr.ipv4_loopback? == false
      end
    end
  end

  def self.save_domains(domains)
    domain_file = File.open(SystemConfig.DomainsFile, 'w')
    begin
      domain_file.write(domains.to_yaml)
    ensure
      domain_file.close
    end
    true
  end

  def self.load_domains
    if File.exist?(SystemConfig.DomainsFile) == false
      domains_file = File.open(SystemConfig.DomainsFile, 'w')
      domains_file.close
      {}
    else
      domains_file = File.open(SystemConfig.DomainsFile, 'r')
      begin
      domains = YAML::load(domains_file)
    ensure
      domains_file.close
    end
      SystemDebug.debug(SystemDebug.system,:loading_domain_list, domains.to_s)
      domains
    end
  end

  def self.list_domains
    domains = DNSHosting.load_domains
    domains
  end

  def self.add_domain(params)
    domains = load_domains
    domains[params[:domain_name]] = params
    save_domains(domains)
  end

  def self.rm_domain(domain)
    domains = load_domains
    if domains.key?(domain)
      domains.delete(domain)
      save_domains(domains)
    else
      raise EnginesException.new(error_hash('failed_to_find_domain' + domain + 'in ', domains.to_s))
    end
  end

  def self.update_domain(old_domain_name, params)
    domains = load_domains
    domains.delete(old_domain_name)
    params.delete(:original_domain_name) if params.key?(:original_domain_name)
    domains[params[:domain_name]] = params
    save_domains(domains)
  end
end
