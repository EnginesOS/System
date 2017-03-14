module ManagedUtilities
  
  
  
  def loadManagedUtility(utility_name)

    return log_error_mesg('No utility name', utility_name) if utility_name.nil? || utility_name.length == 0
#    yaml_file_name = SystemConfig.RunDir + '/utilities/' + utility_name + '/running.yaml'
    yaml_file_name = SystemConfig.RunDir + '/utilities/' + utility_name + '/config.yaml' #unless File.exist?(yaml_file_name)
    return log_error_mesg('No Utility file', utility_name) unless File.exist?(yaml_file_name)
    return log_error_mesg('Utility File Locked',yaml_file_name) if is_container_conf_file_locked?(SystemConfig.RunDir + '/utilities/' + utility_name)
    yaml_file = File.read(yaml_file_name)
    ts = File.mtime(yaml_file_name)
    managed_utility = ManagedUtility.from_yaml(yaml_file, @engines_api.container_api)
    return engine if managed_utility.nil? || managed_utility.is_a?(EnginesError)

     managed_utility
  rescue StandardError => e
    unless utility_name.nil?
      unless managed_utility.nil?
        managed_utility.last_error = 'Failed To get Managed Utility ' + utility_name + ' ' + e.to_s
        log_error_mesg(managed_utility.last_error, e)
      end
    else
      log_error_mesg('nil Utility Name', utility_name)
    end
    log_exception(e)
  end
end