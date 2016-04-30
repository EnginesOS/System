module PublicApiSystemCertificates
  
def get_system_ca
return "No CA found" unless File.exists?(SystemConfig.EnginesInternalCA)
File.read(SystemConfig.EnginesInternalCA)

rescue StandardError => e
return log_exception(e,'Failed to load CA')
end

  def upload_ssl_certificate(params)
    return log_error_mesg('invalid parameter', 'upload Cert ', params.to_s) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return log_error_mesg('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
    return  @system_api.upload_ssl_certificate(params)
  
  end
  
  def get_cert(domain)
    return @system_api.get_cert(domain)
    rescue StandardError => e
        return log_exception(e,'Failed to load cert',domain)
  end
  
  def remove_cert(domain)
     return @system_api.remove_cert(domain)
     rescue StandardError => e
         return log_exception(e,'Failed to remove cert',domain)
   end
   
  def list_certs
    return @system_api.list_certs()
      rescue StandardError => e
          return log_exception(e,'Failed to list certs')
  end
  
end
