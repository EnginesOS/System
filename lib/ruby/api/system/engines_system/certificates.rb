module Certificates
  def upload_ssl_certificate(params)

    cert_file = File.new('/home/app/tmp/' + params[:domain_name] + '.cert','w+')
    cert_file.write(params[:certificate])
    cert_file.close
    key_file = File.new('/home/app/tmp/' + params[:domain_name] + '.key','w+')
    key_file.write(params[:key])
    key_file.close
    flag = ''
    flag = ' -d' if params[:set_as_default] == true
    res = SystemUtils.execute_command('/opt/engines/bin/install_cert.sh ' + flag  + params[:domain_name]  )
    return true if res[:result] == 0
    @last_error = res[:stderr]
    return false
  end
  
  def list_certs
    certs = []  
      p :certs_from
      p SystemConfig.CertificatesDir

    Dir.glob( SystemConfig.CertificatesDir + '/*.crt').each do |cert_file|
      p :cert
      p cert_file
      certs.push(cert_file)
    end
    certs
    rescue StandardError =>e     
        log_exception(e)
  end
  
  def get_cert(domain)
    File.read(SystemConfig.CertificatesDir + '/' + domain.to_s + '.crt')
    rescue StandardError =>e     
           log_exception(e)

  end
end