module ManagedServiceConfigurations
  
  def run_configurator(configurator_params)
      return log_error_mesg('service not running ',configurator_params) unless is_running?
      return log_error_mesg('service missing cont_userid ',configurator_params) if check_cont_uid == false
      cmd = 'docker exec -u ' + @cont_userid.to_s + ' ' +  @container_name.to_s + ' /home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh \'' + SystemUtils.service_hash_variables_as_str(configurator_params).to_s + '\''
      result = {}
      thr = Thread.new { result = SystemUtils.execute_command(cmd) }
      thr.join
      @last_error = result[:stderr] # Dont log just set
      return result
    end
  
    def retrieve_configurator(configurator_params)
      @container_api.retrieve_configurator(self, configurator_params)
    end

    
end