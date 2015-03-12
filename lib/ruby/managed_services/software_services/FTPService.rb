


require_relative "SoftwareService.rb"

class FTPService < SoftwareService
  def add_consumer_to_service(site_hash)
    site_hash[:variables][:persistant]=true
    return  add_ftp_service(site_hash)
  end

  def rm_consumer_from_service (site_hash)
    return  rm_ftp_service(site_hash)
  end
  
  def add_ftp_service(site_hash)
    
  end
  
  def rm_ftp_service(site_hash)
    
  end

  def get_site_hash(site_hash)
    site_hash[:service_type]='ftp'
    site_hash[:publisher_namespace] = "EnginesSystem"
    return site_hash
  end

  



end 