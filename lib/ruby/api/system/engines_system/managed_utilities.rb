module ManagedUtilities
  
  
  
  def loadManagedUtility(utility_name)

    raise EnginesException.new(error_hash('No utility name', utility_name)) if utility_name.nil? || utility_name.length == 0
#    yaml_file_name = SystemConfig.RunDir + '/utilities/' + utility_name + '/running.yaml'
    yaml_file_name = SystemConfig.RunDir + '/utilities/' + utility_name + '/config.yaml' #unless File.exist?(yaml_file_name)
    raise EnginesException.new(error_hash('No Utility file', utility_name)) unless File.exist?(yaml_file_name)
    raise EnginesException.new(error_hash('Utility File Locked', yaml_file_name)) if is_container_conf_file_locked?(SystemConfig.RunDir + '/utilities/' + utility_name)
    yaml_file = File.read(yaml_file_name)
    ts = File.mtime(yaml_file_name)
    ManagedUtility.from_yaml(yaml_file, @engines_api.container_api)
  end
end