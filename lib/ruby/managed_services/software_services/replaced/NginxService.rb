require_relative  "../ManagedService.rb"

class NginxService < ManagedService
  def add_consumer_to_service(service_hash)
    puts "add"
    p  service_hash
    return  @core_api.register_site(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    puts "rm"
    p  service_hash
    return  @core_api.deregister_site(service_hash)
  end

  def create_service_hash(engine)

    proto ="http https"
    case engine.protocol
    when :https_only
      proto="https"
    when :http_and_https
      proto ="http https"
    when :http_only
      proto="http"
    end
    #
    #    p :proto
    #    p proto

    service_hash = Hash.new()
    service_hash[:variables] = Hash.new
    service_hash[:parent_engine]=engine.containerName
    service_hash[:variables][:parent_engine]=engine.containerName
    service_hash[:variables][:name]=engine.containerName
    service_hash[:service_handle] =  engine.fqdn
    service_hash[:variables][:container_type]=engine.ctype
    service_hash[:variables][:fqdn]=engine.fqdn
    service_hash[:variables][:port]=engine.port.to_s
    service_hash[:variables][:proto]= proto
    service_hash[:type_path] = 'nginx'
    service_hash[:publisher_namespace] = "EnginesSystem"
    SystemUtils.debug_output("create nginx Hash",service_hash)
    return service_hash

  end

end 