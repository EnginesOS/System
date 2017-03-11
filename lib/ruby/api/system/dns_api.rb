require '/opt/engines/lib/ruby/api/system/errors_api.rb'

class DNSApi < ErrorsApi
  def initialize(service_manager)
    @service_manager = service_manager
  end

  def add_domain(params)
    r = ''
    return r unless ( r = DNSHosting.add_domain(params))
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
     @service_manager.add_service(service_hash)

  rescue StandardError => e
    log_error_mesg('Add self hosted domain exception', params.to_s)
    log_exception(e)
  end

  def update_domain(params)
    r = ''
    old_domain_name = params[:original_domain_name]
    return r unless ( r = DNSHosting.update_domain(old_domain_name, params))
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

    @service_manager.deregister_non_persistent_service(service_hash)
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:variables][:ip] = get_ip_for_hosted_dns(params[:internal_only])
      r = ''
    return @service_manager.register_non_persistent_service(service_hash) if ( r =  @service_manager.add_service(service_hash))
     r
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def remove_domain(params)
    r = ''
    return r unless (r = DNSHosting.rm_domain(params))
    return true if params[:self_hosted] == false
    service_hash = {}
    service_hash[:parent_engine] = 'system'
    service_hash[:variables] = {}
    service_hash[:variables][:domain_name] = params[:domain_name]
    service_hash[:service_handle] = params[:domain_name] + '_dns'
    service_hash[:container_type] = 'system'
    service_hash[:publisher_namespace] = 'EnginesSystem'
    service_hash[:type_path] = 'dns'
    if (r =  @service_manager.delete_service(service_hash)) == true
      @service_manager.deregister_non_persistent_service(service_hash)
      @service_manager.delete_service_from_engine_registry(service_hash)
      return true
    end
     r
  rescue StandardError => e
    log_exception(e)
  end

  def self.list_domains
    return DNSHosting.list_domains
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def get_ip_for_hosted_dns(internal)
    return DNSHosting.get_local_ip if internal
    open('https://jsonip.com/') { |s| JSON::parse(s.string,:symbolize_keys => true)[:ip] }
  end

end