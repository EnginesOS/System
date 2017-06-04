#require 'yajl'

class SoftwareServiceDefinition
  attr_reader :accepts,
  def SoftwareServiceDefinition.from_yaml(yaml)
    begin
      # p yaml.path
      serviceDefinition = symbolize_keys(YAML::load(yaml))
      serviceDefinition[:persistent] = serviceDefinition[:persistent] unless serviceDefinition.key?(:persistent)
      return serviceDefinition
    rescue Exception=>e
      raise EnginesException.new(self.error_hash('Problem loading Yaml', yaml))
    end
  end

  def self.software_service_definition(params)
    SystemUtils.log_error_mesg('Missing params', params.to_s) if params[:publisher_namespace].nil?
    SystemUtils.log_error_mesg('Missing params', params.to_s) if params[:type_path].nil?

    SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace] )
  rescue Exception=>e
    raise EnginesException.new(self.error_hash('Problem Service defl', params))
  end

  # Find the assigned service container_name from teh service definition file
  def SoftwareServiceDefinition.get_software_service_container_name(params)
    server_service =  self.software_service_definition(params)
    raise EnginesException.new(self.error_hash('Failed to load service definitions', params)) if server_service.nil? || server_service == false
    server_service[:service_container]
  end

  def SoftwareServiceDefinition.consumer_params(service_hash)
    ret_val = []
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    SystemDebug.debug(SystemDebug.services,:SERVICE_Constants, :loaded, service_hash[:type_path], service_hash[:publisher_namespace], service_def)
    return ret_val if service_def.nil?
    return ret_val unless service_def.key?(:consumer_params)
    consumer_params = service_def[:consumer_params]
    return retval unless consumer_params.is_a?(Hash)
    consumer_params
  end

  def SoftwareServiceDefinition.configurators(service_hash)
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path] ,service_hash[:publisher_namespace])
    return service_def if service_def.nil?
    service_def = service_def[:configurators]
    service_def
  end

  def self.summary(definition)
    {
      title: definition[:title],
      persistent: definition[:persistent],
      publisher_namespace: definition[:publisher_namespace],
      type_path: definition[:type_path],
      description: definition[:description],
      service_container: definition[:service_container]
    }
  end

  def SoftwareServiceDefinition.service_constants(service_hash)
    ret_val = []
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    SystemDebug.debug(SystemDebug.services, :SERVICE_Constants, :loaded, service_hash[:type_path], service_hash[:publisher_namespace], service_def)
    return ret_val unless service_def.key?(:constants)
    SystemDebug.debug(SystemDebug.services, :SERVICE_Constants,:with, service_def[:constants])
    constants = service_def[:constants]
    return retval unless constants.is_a?(Hash)
    SystemDebug.debug(SystemDebug.services, :SERVICE_Constants, constants)
    constants.values.each do |env_variable_pair|
      SystemDebug.debug(SystemDebug.services, :env_variable_pair, env_variable_pair)
      name = env_variable_pair[:name]
      value = env_variable_pair[:value]
      # initialize(name, value, setatrun, mandatory, build_time_only,label, immutable)
      owner = []
      owner[0] = 'service_consumer'
      owner[1] = service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + ':' + name
      env = EnvironmentVariable.new(name, value, false, true, false, service_hash[:type_path] + name, true, owner)
      SystemDebug.debug(SystemDebug.services, :SERVICE_Constants, :new_env ,env)
      ret_val.push( env) # env_name , value
    end
    ret_val
  end

  def SoftwareServiceDefinition.service_environments(service_hash)
    retval = Array.new
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    if  service_def != nil
      owner= []
      owner[0]= 'service_consumer'
      path = service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + ':'

      service_environment_variables = service_def[:target_environment_variables]
      service_variables = service_def[:consumer_params]
      SystemDebug.debug(SystemDebug.services,:SERVICE_ENVIRONMENT_VARIABLES, service_environment_variables)
      if service_environment_variables != nil
        service_environment_variables.values.each do |env_variable_pair|
          env_name = env_variable_pair[:environment_name]
          value_name = env_variable_pair[:variable_name]
          value = service_hash[:variables][value_name.to_sym]
          owner[1] = path + value_name
          immutable = service_variables[value_name.to_sym][:immutable]
          build_time_only = service_variables[value_name.to_sym][:build_time_only]
          setatrun = service_variables[value_name.to_sym][:ask_at_build_time]
          mandatory = service_variables[value_name.to_sym][:mandatory]
          retval.push( EnvironmentVariable.new(env_name, value, setatrun, mandatory, build_time_only, value_name, immutable, owner)) # env_name , value

        end                                                      #(name,value,setatrun,mandatory,build_time_only,label,immutable)
      end
    else
      raise EnginesException.new(self.error_hash('Failed to load service definition', service_hash))
    end
    SystemDebug.debug(SystemDebug.builder, :COMPLETE_SERVICE_ENVS, retval)
    return retval

  end

  def SoftwareServiceDefinition.find(service_type, provider)
    if service_type == nil || provider == nil
      return SystemUtils.log_error_mesg('missing params:' +  provider.to_s  + '/' + service_type.to_s + ' ' + caller.to_s )
    end
    dir = SystemConfig.ServiceTemplateDir + '/' + provider
    if Dir.exist?(dir)
      service_def = SoftwareServiceDefinition.load_service_def(dir, service_type)
      if service_def == nil
        raise EnginesException.new(self.error_hash('Nil Service type', provider.to_s + '/' + service_type.to_s ))
      end
      return service_def #.to_h
    end

    raise EnginesException.new(self.error_hash('No Dir', dir.to_s + ':'  + service_type.to_s + ':'+ provider.to_s ))
    #  rescue Exception=>e
    #    SystemDebug.debug(SystemDebug.services,:SERVICE_EXCEPT,:loaded,service_hash[:type_path],service_hash[:publisher_namespace])
    #    SystemUtils.log_error_mesg('Error ' ,provider.to_s + '/' + service_type.to_s )
    #    SystemUtils.log_exception(e)

  end

  def SoftwareServiceDefinition.load_service_def(dir, service_type)
    service_name = File.basename(service_type)
    filename=dir + '/' + service_type + '/' + service_name + '.yaml'
    if File.exist?(filename)
      yaml = File.read(filename)
      return SoftwareServiceDefinition.from_yaml(yaml)
    end
    raise EnginesException.new(self.error_hash('No Such Definitions File!', dir.to_s + '/' + service_type.to_s + ' ' + filename.to_s))
  end

  def search_dir(dir,service_type)
    SoftwareServiceDefinition.search_dir(dir, service_type)
  end

  def SoftwareServiceDefinition.search_dir(dir, service_type)
    root = dir
    if Dir.exists?(dir)
      Dir.foreach(dir) do |service_dir_entry|
        if Dir.exist?(service_dir_entry) == true && service_dir_entry.start_with?('.') ==false
          search_dir(root + '/' + service_dir_entry, service_type)
        else
          service_name = File.basename(service_type)
          if File.exist?(root + '/' + service_dir_entry + '/' + service_type + '/' + service_name  + '.yaml'   )
            return load(dir,service_type)
          end
        end
      end
    end
  end

  def SoftwareServiceDefinition.is_persistent?(params)
    service = SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
    if service == nil
      return nil
    end
    return false unless service.key?(:persistent)
    return service[:persistent]
  end

  def SoftwareServiceDefinition.is_soft_service?(service_hash)
    service = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    return false unless service.key?(:soft_service)
    service_hash[:soft_service] = service[:soft_service]
    service[:soft_service]
  end

  def SoftwareServiceDefinition.service_handle_field(params)
    service = SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
    service[:service_handle_field]
  end

  def self.error_hash(mesg, params = nil)
    r = self.error_type_hash(mesg, params)
    r[:error_type] = :error
    r
  end

  def self.error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :engines_core,
      params: params }
  end
end