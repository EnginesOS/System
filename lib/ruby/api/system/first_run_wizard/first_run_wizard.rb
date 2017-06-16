class FirstRunWizard <ErrorsApi
  attr_reader  :error, :sucess

  require_relative 'first_run_certs.rb'
  require_relative 'first_run_dns.rb'
  require_relative 'first_run_passwords.rb'
  require_relative 'first_run_params_validation.rb'
  include FirstRunCerts
  include FirstRunDNS
  include FirstRunPasswords
  include FirstRunParamsValidation
  require_relative 'engines_first_run_errors.rb'
  include EnginesFirstRunErrors
  def initialize(params)
    @sucess = false
    @first_run_params = params
  end

  def apply(api)
    if @has_ran == true
      false
    else
      @api = api
      SystemDebug.debug(SystemDebug.first_run, :applyin, @first_run_params)
      return log_error_mesg('failed to validate first run params') unless validate_params(@first_run_params)
      refs = SystemPreferences
      prefs.set_country_code(@first_run_params[:country_code]) if @first_run_params.key?(:country_code)
      prefs.set_langauge_code(@first_run_params[:lang_code]) if @first_run_params.key?(:lang_code)
      @api.set_timezone(@first_run_params[:timezone]) if @first_run_params.key?(:timezone)
      return false unless setup_dns
      # certs = @api.loadManagedService('cert_auth')
      # certs.create_service

      setup_certs
      setup_system_password(@first_run_params[:admin_password], @first_run_params[:admin_email])
      @sucess = true
      mark_as_run #if SystemDebug.debug(SystemDebug.first_run)
      true
    end
  end

  def mark_as_run
    @has_ran = true
  end

  def FirstRunWizard.required?
    if File.exist?(SystemConfig.FirstRunRan) == false
      true
    else
      false
    end
  end
  # FIXME: and put in it's own class or even service

end
