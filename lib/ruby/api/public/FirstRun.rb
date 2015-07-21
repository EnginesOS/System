class FirstRun
  attr_reader  :error,:sucess
   
  def initialize(params)
    @sucess = false
    @error = "None"
    @first_run_params = params
    
    
  end 
  
  def apply(api)
    
    mysql_password_configurator(@first_run_params[:mysql_password])
    gui_password_configurator(@first_run_params[:admin_password])
    ssh_password_configurator(@first_run_params[:ssh_password])
    api.set_default_domain(params)
    
      if @first_run_params.has_key?(:ssh_key)
        ssh_key_configurator(@first_run_params[:ssh_key])      
      end
    
    
    create_ca(@first_run_params[])
    
    create_default_cert
    
    restart_ssl_dependant_services
    
    mark_as_run
  end
  
  def mark_as_run
    f = File.new(SysConfig.FirstRunRan,"w")
             date = DateTime.now
             f.puts(date.to_s)
             f.close  
  end
  #  {"admin_password"=>"EngOS2014", "admin_password_confirmation"=>"EngOS2014", "ssh_password"=>"qCCedhQCb2", "ssh_password_confirmation"=>"qCCedhQCb2", "mysql_password"=>"TpBGZmQixr", "mysql_password_confirmation"=>"TpBGZmQixr", "psql_password"=>"8KqfESacSg", "psql_password_confirmation"=>"8KqfESacSg", "smarthost_hostname"=>"203.14.203.141", "smarthost_username"=>"", "smarthost_password"=>"", "smarthost_authtype"=>"", "smarthost_port"=>"", "default_domain"=>"engines.demo", "ssl_person_name"=>"test", "ssl_organisation_name"=>"test", "ssl_city"=>"test", "ssl_state"=>"test", "ssl_country"=>"AU"}
      
  #    params[:mail_name] = "smtp." + params[:default_domain]
  #    @core_api.setup_email_params(params)
           
          
     # @core_api.set_database_password("mysql_server",params)              
      #@core_api.set_database_password("pgsql_server",params)    
          
      #@core_api.set_engines_ssl_pw(params)
      

end