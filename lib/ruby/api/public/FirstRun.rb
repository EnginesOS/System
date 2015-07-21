class FirstRun
  attr_reader  :error,:sucess
  def initialize(params)
    @sucess = false
    @error = "None"
    @first_run_params = params

  end

  def apply(api)

    if mysql_password_configurator(@first_run_params[:mysql_password]) == false
      @error="Fail to setup mysql password " + api.last_error()
      return false
    end

    if ssh_password_configurator(@first_run_params[:ssh_password]) == false
      @error="Fail to setup ssh password " + api.last_error()
      return false
    end

    domain_hash = get_domain_params(@first_run_params)
    if api.add_domain(domain_hash) == false
      @error="Fail to add domain " + api.last_error() + " " + domain_hash
      return false
    end

    if api.set_default_domain(domain_hash)  == false
      @error="Fail to set default domain " + api.last_error() + " " + domain_hash
      return false
    end

    if @first_run_params.has_key?(:ssh_key) == true
      if ssh_key_configurator(@first_run_params[:ssh_key]) == false
        @error="Fail to setup ssh key " + api.last_error()
        return false
      end
    end
    #
    #
    #    create_ca(@first_run_params[])
    #
    #    create_default_cert
    #
    #    restart_ssl_dependant_services
    @sucess=true
    mark_as_run
  end

  def get_domain_params(params)
    domain_hash = Hash.new()
    domain_hash[:default_domain]=params[:domainame]
    #self host
    #internal only
    return domain_hash
  end

  def mysql_password_configurator(password)
    service_param = Hash.new
    service_param[:service_name] = "mysql_server"
    service_param[:configurator_name] = "db_master_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:db_master_pass] = password
    return  update_service_configuration(service_param)
  end

  def ssh_password_configurator(passwd)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_pass] = password
    return  update_service_configuration(service_param)
  end

  def ssh_key_configurator(key)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_key"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_key] = key
    return  update_service_configuration(service_param)

  end

  def mark_as_run
    f = File.new(SysConfig.FirstRunRan,"w")
    date = DateTime.now
    f.puts(date.to_s)
    f.close
  end


  def FirstRun.required?
    if File.exists?(SysConfig.FirstRunRan) ==false
      return true
    end
    return false
  end

  #FIXME and put in it's own class or even service
  require 'r509'

  def create_ca(ca_params)
    csr = R509::CSR.new(
      :subject => [
        ['CN','somedomain.com'],
        ['O','My Org'],
        ['L','City'],
        ['ST','State'],
        ['C','US']
      ]
    )
    
    #key = R509::PrivateKey.new(:type => "RSA", :bit_length => 1536)
    key = R509::PrivateKey.new(:type => "RSA", :bit_length => 2048)
   
    encrypted_pem = key.to_encrypted_pem("aes256","my-password")
    # or write it to disk
    key.write_encrypted_pem("/tmp/key","aes256","my-password")
    not_before = Time.now.to_i
    not_after = Time.now.to_i+3600*24*7300
    
    cert = R509::CertificateAuthority::Signer.selfsign(
      :csr => csr,
      :not_before => not_before,
      :not_after => not_after
    )
  ####  
    cert_pem = File.read("/tmp/cert")
    key_pem = File.read("/tmp/key")
    cert = R509::Cert.new(
      :cert => cert_pem,
      :key => key_pem
    )
    config = R509::Config::CAConfig.new(
      :ca_cert => cert
    )

  end

  def create_default_cert

  end
end