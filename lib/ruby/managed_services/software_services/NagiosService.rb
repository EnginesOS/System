require_relative "SoftwareService.rb"

class NagiosService < SoftwareService
  def add_consumer_to_service(service_hash)
    return  add_monitor(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  rm_monitor(service_hash)
  end

end 