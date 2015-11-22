module DomainOperations
  require '/opt/engines/lib/ruby/system/dnshosting.rb'

  def add_domain_service(params)

    # if domain name ends with .local check for and create if needed avahi
    # turn on flag to add zero conf dns with dns registration
    # cycle through engines and serices turning on zero_conf where conf_zero_conf=true
    # also self host .local regardless so windows can point to dns and pretend to understand
    # bonjournoe without happing it installed and there fore bypass the cname issue with windows
    return true if add_domain(params)
    log_error_mesg(@last_error, params)
  end

  def update_domain_service(params)
    return true if update_domain(params)
    log_error_mesg(@last_error, params)
  end

  def remove_domain_service(params)
    return true if remove_domain(params)
    log_error_mesg(@last_error, params)
  end

  def list_domains
    return DNSHosting.list_domains
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  private

  def add_domain(params)
    return false unless DNSHosting.add_domain(params)
    return true unless params[:self_hosted]
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
    if params[:internal_only]
      service_hash[:variables][:ip_type] = 'lan'
    else
      service_hash[:variables][:ip_type] = 'gw'
    end
    return true if @service_manager.create_and_register_service(service_hash)
    @last_error = @service_manager.last_error
    return false
  rescue StandardError => e
    log_error_mesg('Add self hosted domain exception', params.to_s)
    log_exception(e)
  end

  def update_domain(params)
    old_domain_name = params[:original_domain_name]
    return false unless DNSHosting.update_domain(old_domain_name, params)
    return true unless params[:self_hosted]
    service_hash =  {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    if params.key?(:original_domain_name)
      service_hash[:variables][:domain_name] = old_domain_name
      service_hash[:service_handle] = old_domain_name + '_dns'
    else
      service_hash[:variables][:domain_name] = params[:domain_name]
      service_hash[:service_handle] = params[:domain_name] + '_dns'
    end
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    @service_manager.delete_service(service_hash)
    #@service_manager.deregister_non_persistant_service(service_hash)
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
    return  @service_manager.create_and_register_service(service_hash)
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def remove_domain(params)
    return false if DNSHosting.rm_domain(params) == false
    return true if params[:self_hosted] == false
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
   return @service_manager.delete_service(service_hash) 

  rescue StandardError => e
    log_exception(e)
  end

  def get_ip_for_hosted_dns(internal)
    return DNSHosting.get_local_ip if internal
    open('http://jsonip.com/') { |s| JSON::parse(s.string)['ip'] }
  end

end