require_relative  "../ManagedService.rb"

class DNSService < ManagedService

  #
  #  def get_service_hash(service_hash)
  #    if service_hash.is_a?(Hash)
  #      return service_hash
  #    else
  #      service_hash = create_service_hash(service_hash)
  #    end
  #
  #    return service_hash
  #  end
  def create_service_hash engine
    p :new_Site_has_for
    p engine.containerName
    service_hash = Hash.new()
    service_hash[:type_path] = 'dns'
    service_hash[:variables] = Hash.new
    service_hash[:variables][:parent_engine]=engine.containerName
    service_hash[:parent_engine]=engine.containerName
    service_hash[:variables][:name]=engine.containerName
    service_hash[:variables][:container_type]=engine.ctype
    service_hash[:variables][:hostname]=engine.hostName
    service_hash[:variables][:ip]=engine.get_ip_str.to_s
    service_hash[:publisher_namespace] = "EnginesSystem"
    service_hash[:service_handle]=engine.hostName
    SystemUtils.debug_output("create dns Hash",service_hash)

    return service_hash
  end

  def get_service_hash service_hash
    service_hash = super
    if service_hash[:variables].has_key?(:ip) == false
      service_hash[:variables][:ip] = DNSHosting.get_local_ip
    end
    return service_hash
  end

  def add_consumer_to_service(service_hash)

    ip_str = service_hash[:variables][:ip]
    hostName = service_hash[:variables][:hostname]
    puts hostName
    p ip_str
    if ip_str != nil && ip_str.length > 7 #fixme need to check valid ip and that host is valid
      return  @core_api.register_dns(service_hash[:variables][:hostname],ip_str)
    else
      return false
    end

  end

  def rm_consumer_from_service (service_hash)
    if service_hash == nil
      return false
    end
    p :deregister
    p service_hash[:variables][:name]
    return  @core_api.deregister_dns(service_hash[:variables][:hostname])
  end

end