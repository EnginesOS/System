module PublicApiSystemCertificates
  
def get_system_ca
  @system_api.get_system_ca
#return "No CA found" unless File.exists?(' /opt/engines/etc/ca/engines_internal_ca.crt') # DO USE SystemConfig.EnginesInternalCA
#File.read( '/opt/engines/etc/ca/engines_internal_ca.crt') #SystemConfig.EnginesInternalCA)
#
#rescue StandardError => e
#return log_exception(e,'Failed to load CA')
end

  def upload_ssl_certificate(params)
    return log_error_mesg('invalid parameter', 'upload Cert ', params.to_s) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return log_error_mesg('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
      @system_api.upload_ssl_certificate(params)
  
  end
  def generate_cert(params)
    #    service_param[:parent_engine] = 'system'
    #      service_param[:service_handle] = 'default_ssl_cert'
    #      service_param[:variables] = {}
    #      service_param[:variables][:wild] = 'yes'
    #      service_param[:variables][:cert_name] = 'engines'
    #      service_param[:variables][:country] = params[:ssl_country]
    #      service_param[:variables][:state] = params[:ssl_state]
    #      service_param[:variables][:city] = params[:ssl_city]
    #      service_param[:variables][:organisation] = params[:ssl_organisation_name]
    #      service_param[:variables][:person] = params[:ssl_person_name]
    #      service_param[:variables][:domainname] =  params[:domain_name] #params[:default_domain]
    #      service_param[:variables][:service_handle] = 'default_ssl_cert'
      @system_api.generate_cert(params)
     rescue StandardError => e
          log_exception(e,'Failed to generate cert',params)
   end  
  def get_cert(domain)
     @system_api.get_cert(domain)
    rescue StandardError => e
         log_exception(e,'Failed to load cert',domain)
  end
  
  def remove_cert(domain)
      @system_api.remove_cert(domain)
     rescue StandardError => e
          log_exception(e,'Failed to remove cert',domain)
   end
   
  def list_certs
     @system_api.list_certs()
      rescue StandardError => e
           log_exception(e,'Failed to list certs')
  end
  
end
