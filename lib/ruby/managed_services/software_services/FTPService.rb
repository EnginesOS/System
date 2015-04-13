require_relative "SoftwareService.rb"

class FTPService < SoftwareService
  def add_consumer_to_service(service_hash)

    return  add_ftp_service(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  rm_ftp_service(service_hash)
  end

  def add_ftp_service(service_hash)

  end

  def rm_ftp_service(service_hash)

  end
  #
  #  def get_service_hash(service_hash)
  #    service_hash[:service_type]='ftp'
  #
  #    service_hash[:publisher_namespace] = "EnginesSystem"
  #    return service_hash
  #  end

end 