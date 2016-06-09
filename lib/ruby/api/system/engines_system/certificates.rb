module Certificates
  def upload_ssl_certificate(params)

    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)
    
    certs_service.perform_action('import_cert',params[:domain_name], params[:certificate] + params[:key])
    
#    
#    cert_file = File.new('/home/app/tmp/' + params[:domain_name] + '.cert','w+')
#    cert_file.write(params[:certificate])
#    cert_file.close
#    key_file = File.new('/home/app/tmp/' + params[:domain_name] + '.key','w+')
#    key_file.write(params[:key])
#    key_file.close
#    flag = ''
#    flag = ' -d ' if params[:set_as_default] == true
#    res = SystemUtils.execute_command('/opt/engines/system/scripts/ssh/install_cert.sh ' + flag  + params[:domain_name]  )
#    return true if res[:result] == 0
#    @last_error = res[:stderr]
#    return log_error_mesg(res[:stderr])
    rescue StandardError =>e
        log_exception(e)
  end

  def remove_cert(domain)
    certs_service = loadManagedService('cert_auth')
        return certs_service if certs_service.is_a?(EnginesError)
        
        certs_service.perform_action('remove_cert',params[:domain_name])
  end
#    res = SystemUtils.execute_command('/opt/engines/system/scripts/ssh/remove_cert.sh ' + domain )
#    return true if res[:result] == 0
#    @last_error = res[:stderr]
#    return  log_error_mesg(res[:stderr])
#
#  end

  def list_certs
    certs_service = loadManagedService('cert_auth')
       return certs_service if certs_service.is_a?(EnginesError)
       certs_service.perform_action('list_certs',nil)
 
#    certs = []
#    p :certs_from
#    p SystemConfig.CertificatesDir
#
#    Dir.glob( SystemConfig.CertificatesDir + '/*.crt').each do |cert_file|
#      p :cert
#      cert_file = File.basename(cert_file)
#      cert_file.sub!(/\.crt/,'')
#      p cert_file
#      certs.push(cert_file)
#    end
#    certs
  rescue StandardError =>e
    log_exception(e)
  end

  #  def get_cert(domain_name)
  #    domain_name = 'engines' if domain_name == 'default'
  #    return log_error_mesg('Certificate file not found ' + domain_name.to_s) unless File.exist?(SystemConfig.CertificatesDir + '/' + domain_name.to_s + '.crt')
  #    File.read(SystemConfig.CertificatesDir + '/' + domain_name.to_s + '.crt')
  #    rescue StandardError =>e
  #           log_exception(e)
  #
  #  end
  def get_system_ca

    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)
    certs_service.perform_action('system_ca',nil)
    rescue StandardError =>e
        log_exception(e)
  end

  def get_cert(domain_name) 
    certs_service = loadManagedService('cert_auth')

    return certs_service if certs_service.is_a?(EnginesError)

    domain_name = 'engines' if domain_name == 'default'
    certs_service.perform_action('fetch_cert', domain_name)
    #        end
    #        return log_error_mesg('Certificate file not found ' + domain_name.to_s) unless File.exist?(SystemConfig.CertificatesDir + '/' + domain_name.to_s + '.crt')
    #        File.read(SystemConfig.CertificatesDir + '/' + domain_name.to_s + '.crt')
  rescue StandardError =>e
    log_exception(e)

  end

end