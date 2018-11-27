module DomainOperations
  require '/opt/engines/lib/ruby/system/dnshosting.rb'
  require_relative 'service_manager_access.rb'

  def add_domain_service(params)

    # if domain name ends with .local check for and create if needed avahi
    # turn on flag to add zero conf dns with dns registration
    # cycle through engines and serices turning on zero_conf where conf_zero_conf=true
    # also self host .local regardless so windows can point to dns and pretend to understand
    # bonjournoe without happing it installed and there fore bypass the cname issue with windows
    add_domain(params)
  end

  def update_domain_service(params)
    update_domain(params)
  end

  def remove_domain_service(params)
    remove_domain(params)
  end

  def list_domains
    DNSHosting.list_domains
  end

  def domain_name(domain_name)
    domains = DNSHosting.load_domains
    domains[domain_name]
  end

  def add_domain(params)
     STDERR.puts(' ADD DOMAIN VARIABLE ' + params.to_s)
    DNSHosting.add_domain(params)
    if params[:self_hosted]
      service_hash = {
        parent_engine: 'system',
        variables: {
        domain_name: params[:domain_name],
        type: 'domain'
        },
        service_handle: params[:domain_name] + '_dns',
        container_type: 'system',
        publisher_namespace: 'EnginesSystem',
        type_path: 'domains'
      }
      if params[:internal_only]
        service_hash[:variables][:wan_or_lan] = 'lan'
       # service_hash[:variables][:ip] =  get_lan_ip_for_hosted_dns()
      else
        service_hash[:variables][:wan_or_lan] = 'wan'
       # service_hash[:variables][:ip] =  get_ext_ip_for_hosted_dns()
      end
         STDERR.puts(' ADD DOMAIN VARIABLES' + service_hash.to_s)
      create_and_register_service(service_hash)
    else
      true
    end
  end

  def update_domain(params)
    #   STDERR.puts(' UPDATE DOMAIN VARIABLES ' + params.to_s)
    old_domain_name = params[:original_domain_name]
    DNSHosting.update_domain(old_domain_name, params)
      service_hash = {
        parent_engine: 'system',
        container_type: 'system',
        publisher_namespace: 'EnginesSystem',
        type_path: 'domains',
        service_handle: params[:domain_name] + '_dns',
        variables: {
        domain_name: params[:domain_name],
        type: 'domain' 
        }
      }
    if params[:self_hosted]
      if params.key?(:original_domain_name)
        service_hash[:variables][:domain_name] = old_domain_name
        service_hash[:service_handle] = old_domain_name + '_dns'
      else
        service_hash[:variables][:domain_name] = params[:domain_name]
        service_hash[:service_handle] = params[:domain_name] + '_dns'
      end

      if params[:internal_only]        
        service_hash[:variables][:wan_or_lan] = 'lan'
        service_hash[:variables][:ip] = get_lan_ip_for_hosted_dns()
      else
        service_hash[:variables][:wan_or_lan] = 'wan'
        service_hash[:variables][:ip] = get_ext_ip_for_hosted_dns()
      end
      STDERR.puts(' COMPLETEd DNS HASH ' + service_hash.to_s )
      begin
        dettach_service(service_hash)
      rescue
      end
      create_and_register_service(service_hash)
    else
      begin
        dettach_service(service_hash)
      rescue
      end
    end   
  end

  def remove_domain(params)
  
    domain_name = params
    domain_name = params[:domain_name] unless params.is_a?(String)
    params = domain_name(domain_name)
    
    raise EnginesException.new(error_hash('Domain not found' + domain_name)) if params.nil?
    raise EnginesException.new(error_hash('no params')) if params.nil?
    raise EnginesException.new(error_hash('Cannot delete default domain!')) if domain_name == default_domain
    DNSHosting.rm_domain(domain_name)
    unless params[:self_hosted] == false
      service_hash = {
        parent_engine: 'system',
        variables:  {
        domain_name: domain_name
        },
        service_handle: domain_name + '_dns',
        container_type: 'system',
        publisher_namespace: 'EnginesSystem',
        type_path: 'domains',
      }
      dettach_service(service_hash)
    end
  end
  private

  def get_lan_ip_for_hosted_dns
    DNSHosting.get_local_ip
  end

  def get_ext_ip_for_hosted_dns
   e_ip = open('https://jsonip.com/') { |s| JSON::parse(s.string)['ip'] }
    STDERR.puts('EX ERR = ' + e_ip.to_s)
    e_ip    
  end

end