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
    SystemDebug.debug(SystemDebug.system,:applyin, @first_run_params)
    return false unless validate_params(@first_run_params)
   # return false unless set_passwords
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
