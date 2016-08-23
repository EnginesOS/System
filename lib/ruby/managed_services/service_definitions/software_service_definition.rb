require 'yajl'

class SoftwareServiceDefinition
  attr_reader :accepts,
#  :author,
#  :title,
#  :description,
#  :service_name,
#  :consumer_params,
#  :setup_params,
#  :dedicated,
#  :service_type,
#  :publisher_namespace,
#  :service_container,
#  :persistent,
#  :target_environment_variables,
#  :service_handle_field
  def SoftwareServiceDefinition.from_yaml( yaml )
    begin
      # p yaml.path
      serviceDefinition = SystemUtils.symbolize_keys(YAML::load( yaml ))
      serviceDefinition[:persistent] =  serviceDefinition[:persistent] unless serviceDefinition.key?(:persistent) 
      return serviceDefinition        
    rescue Exception=>e
      SystemUtils.log_error_mesg('Problem loading Yaml',yaml)
      SystemUtils.log_exception(e)
    end
  end

  def self.software_service_definition(params)
    SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace] )
  end

  #Find the assigned service container_name from teh service definition file
  def SoftwareServiceDefinition.get_software_service_container_name(params)

    server_service =  self.software_service_definition(params)
    return  SystemUtils.log_error_mesg('Failed to load service definitions',params) if server_service.nil? || server_service == false

    return server_service[:service_container]
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
  def SoftwareServiceDefinition.consumer_params(service_hash)
    ret_val = []
            service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
        SystemDebug.debug(SystemDebug.services,:SERVICE_Constants,:loaded,service_hash[:type_path],service_hash[:publisher_namespace],service_def)
        return ret_val if service_def.nil?
        return ret_val unless service_def.key?(:consumer_params)
        consumer_params = service_def[:consumer_params]
         return retval unless consumer_params.is_a?(Hash)
         return consumer_params
        
end

  
  def SoftwareServiceDefinition.configurators(service_hash)
    STDERR.puts(' SoftwareServiceDefinition.configurators ' + service_hash.to_s)
   service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    return service_def if service_def.nil?
    return service_def if service_def.is_a?(EnginesError)
    service_def = service_def[:configurators]
    service_def
#        SystemDebug.debug(SystemDebug.services,:SERVICE_Constants,:loaded,service_hash[:type_path],service_hash[:publisher_namespace],service_def)
#        return ret_val if service_def.nil?
#        return ret_val unless service_def.key?(:consumer_params)
#        consumer_params = service_def[:consumer_params]
#         return retval unless consumer_params.is_a?(Hash)
#         return consumer_params
        
end

  def SoftwareServiceDefinition.service_constants(service_hash)
    ret_val = []
        service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    SystemDebug.debug(SystemDebug.services,:SERVICE_Constants,:loaded,service_hash[:type_path],service_hash[:publisher_namespace],service_def)
    return ret_val if service_def.nil?
    return ret_val unless service_def.key?(:constants)
    SystemDebug.debug(SystemDebug.services,:SERVICE_Constants,:with,service_def[:constants])
    constants = service_def[:constants]
      return retval unless constants.is_a?(Hash)
    SystemDebug.debug(SystemDebug.services,:SERVICE_Constants, constants)
    constants.values.each do |env_variable_pair|  
      SystemDebug.debug(SystemDebug.services,:env_variable_pair, env_variable_pair)
      name = env_variable_pair[:name]
      value = env_variable_pair[:value]      
     # initialize(name, value, setatrun, mandatory, build_time_only,label, immutable)
        env = EnvironmentVariable.new(name,value,false,true,false,service_hash[:type_path] + name,true)
      SystemDebug.debug(SystemDebug.services,:SERVICE_Constants,:new_env,env)
      ret_val.push( env) # env_name , value 
  end
      ret_val
    rescue StandardError => e
       SystemUtils.log_exception(e) 
      
  end
  
  def SoftwareServiceDefinition.service_environments(service_hash)
    retval = Array.new
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    if  service_def != nil
      service_environment_variables = service_def[:target_environment_variables]
      service_variables = service_def[:consumer_params]
      SystemDebug.debug(SystemDebug.services,:SERVICE_ENVIRONMENT_VARIABLES, service_environment_variables)
      if service_environment_variables != nil
        service_environment_variables.values.each do |env_variable_pair|
          env_name = env_variable_pair[:environment_name]
          value_name = env_variable_pair[:variable_name]
          value = service_hash[:variables][value_name.to_sym]
        immutable = service_variables[value_name.to_sym][:immutable]
        build_time_only = service_variables[value_name.to_sym][:build_time_only]
        setatrun = service_variables[value_name.to_sym][:ask_at_build_time]
        mandatory = service_variables[value_name.to_sym][:mandatory]
        retval.push( EnvironmentVariable.new(env_name,value,setatrun,mandatory,build_time_only,
        service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + ':' + value_name,immutable)) # env_name , value
          
        end                                                      #(name,value,setatrun,mandatory,build_time_only,label,immutable)
      end
    else
      SystemUtils.log_error_mesg('Failed to load service definition',service_hash)
    end
  SystemDebug.debug(SystemDebug.builder, :COMPLETE_SERVICE_ENVS, retval)
    return retval

  end

  def SoftwareServiceDefinition.find(service_type, provider)
    if service_type == nil  || provider == nil
      return  SystemUtils.log_error_mesg('missing params:' +  provider.to_s  + '/' + service_type.to_s )
    end
    dir = SystemConfig.ServiceTemplateDir + '/' + provider
    if Dir.exist?(dir)
      service_def = SoftwareServiceDefinition.load_service_def(dir,service_type)
      if service_def == nil
        return SystemUtils.log_error_mesg('Nil Service type',provider.to_s + '/' + service_type.to_s )

      end
      return service_def #.to_h
    end
    return SystemUtils.log_error_mesg('No Dir',dir)   
  rescue Exception=>e
    SystemUtils.log_error_mesg('Error ' ,provider.to_s + '/' + service_type.to_s )
    SystemUtils.log_exception(e)
   
  end

  def SoftwareServiceDefinition.load_service_def(dir,service_type)
    service_name = File.basename(service_type)
    filename=dir + '/' + service_type + '/' + service_name + '.yaml' 
    if File.exist?(filename)
      yaml = File.read(filename)
      return SoftwareServiceDefinition.from_yaml(yaml)
    end
    SystemUtils.log_error_mesg('No Such Definitions File',dir.to_s + '/' + service_type.to_s + ' ' + filename.to_s)
    return nil
  rescue Exception=>e
    SystemUtils.log_error_mesg('Error With',dir.to_s + '/' + service_type.to_s)
    SystemUtils.log_exception(e)
  end

  def search_dir(dir,service_type)
    return SoftwareServiceDefinition.search_dir(dir,service_type)
  end

  def SoftwareServiceDefinition.search_dir(dir,service_type)
    root = dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        if Dir.exist?(service_dir_entry) == true && service_dir_entry.start_with?('.') ==false
          search_dir(root + '/' + service_dir_entry,service_type)
        else
          service_name = File.basename(service_type)
          if File.exist?(root + '/' + service_dir_entry + '/' + service_type + '/' + service_name  + '.yaml'   )
            return load(dir,service_type)
          end
        end
      end
    end
  rescue Exception=>e
    SystemUtils.log_exception(e)
  end

  def SoftwareServiceDefinition.is_persistent?(params)
    service =  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace])
    if service == nil
      return nil
    end
    return false unless service.key?(:persistent)
    return service[:persistent]
  end
  
def SoftwareServiceDefinition.is_soft_service?(service_hash)
  service =  SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
  if service == nil
    return nil
  end
  return false unless service.key?(:soft_service)
  service_hash[:soft_service] = service[:soft_service]
  return service[:soft_service]
end

  def SoftwareServiceDefinition.service_handle_field(params)
    service =  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace])
    if service == nil
      return nil
    end
    return service[:service_handle_field]
  end

  def to_h
    hash = {}
    instance_variables.each {|var|
      symbol = var.to_s.delete('@').to_sym
      hash[symbol] = instance_variable_get(var) }
    return SystemUtils.symbolize_keys(hash)
  rescue Exception=>e
    SystemUtils.log_error_mesg('Exception With to h',self)
    SystemUtils.log_exception(e)
  end
  
  
end