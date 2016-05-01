class FirstRunWizard <ErrorsApi
  attr_reader  :error, :sucess

  require_relative 'first_run_wizard/first_run_certs.rb'
  require_relative 'first_run_wizard/first_run_dns.rb'
  require_relative 'first_run_wizard/first_run_passwords.rb'
  require_relative 'first_run_wizard/first_run_params_validation.rb'
  include FirstRunCerts
  include FirstRunDNS
  include FirstRunPasswords
  include FirstRunParamsValidation
  
  def initialize(params)
    @sucess = false
    @first_run_params = params
  end

  def apply(api)
    @api = api
    SystemDebug.debug(SystemDebug.first_run,:applyin, @first_run_params)
    return log_error_mesg('failed to validate first run params') unless validate_params(@first_run_params)
   # return false unless set_passwords
    #FIX ME check what the key is supposed to be
 #??return false unless mysql_password_configurator(@first_run_params[:gui_password])
    return false unless  setup_dns
    return false unless setup_certs
    @sucess = true
    mark_as_run
  end

  def mark_as_run
    f = File.new(SystemConfig.FirstRunRan, 'w')
    date = DateTime.now
    f.puts(date.to_s)
    f.close
  end

  def FirstRunWizard.required?
    return true if File.exist?(SystemConfig.FirstRunRan) == false
    return false
  end
  # FIXME: and put in it's own class or even service
  

end
