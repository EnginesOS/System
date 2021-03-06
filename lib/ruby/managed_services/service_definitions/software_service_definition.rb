#require 'yajl'

class SoftwareServiceDefinition
  attr_reader :accepts,
  def SoftwareServiceDefinition.from_yaml(yaml)
    begin
      # p yaml.path
      serviceDefinition = symbolize_keys(YAML::load(yaml))
      serviceDefinition[:persistent] = serviceDefinition[:persistent] unless serviceDefinition.key?(:persistent)
      serviceDefinition
    rescue Exception=>e
      raise EnginesException.new(self.error_hash('Problem loading Yaml ' + "\n" +  e.to_s + "\n " + e.backtrace.to_s + "\n", yaml))
    end
  end

  def self.software_service_definition(params)
    raise EnginesException.new(self.error_hash('Nil params')) if params.nil?
    raise EnginesException.new(self.error_hash('Missing params', params)) if params[:publisher_namespace].nil?
    raise EnginesException.new(self.error_hash('Missing params', params)) if params[:type_path].nil?
    SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
  end

  # Find the assigned service container_name from teh service definition file
  def SoftwareServiceDefinition.get_software_service_container_name(params)
    server_service = self.software_service_definition(params)
    raise EnginesException.new(self.error_hash('Failed to load service definitions', params)) if server_service.nil? || server_service == false
    server_service[:service_container]
  end

  def SoftwareServiceDefinition.consumer_params(service_hash)
    ret_val = []
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
   # SystemDebug.debug(SystemDebug.services,:SERVICE_Constants, :loaded, service_hash[:type_path], service_hash[:publisher_namespace], service_def)
    return ret_val if service_def.nil?
    return ret_val unless service_def.key?(:consumer_params)
    consumer_params = service_def[:consumer_params]
    return retval unless consumer_params.is_a?(Hash)
    consumer_params
  end

  def SoftwareServiceDefinition.configurators(service_hash)
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path] ,service_hash[:publisher_namespace])
    return service_def if service_def.nil?
    service_def[:configurators]
  end

  def SoftwareServiceDefinition.actionators(service_hash)
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path] ,service_hash[:publisher_namespace])
    service_def = service_def[:service_actionators] unless service_def.nil?
    [] if service_def.nil?
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
   # SystemDebug.debug(SystemDebug.services, :SERVICE_Constants, :loaded, service_hash[:type_path], service_hash[:publisher_namespace], service_def)
    return ret_val unless service_def.key?(:constants)
   # SystemDebug.debug(SystemDebug.services, :SERVICE_Constants,:with, service_def[:constants])
    constants = service_def[:constants]
    return retval unless constants.is_a?(Hash)
   # SystemDebug.debug(SystemDebug.services, :SERVICE_Constants, constants)
    constants.values.each do |env_variable_pair|
  ret_val.push(EnvironmentVariable.new({name: env_variable_pair[:name], 
                                     value: env_variable_pair[:value], 
                                     mandatory: true,                                      
                                     build_time_only: false, 
                                     owner_path:  service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + ':' + name,
                                     owner_type: 'service_consumer',
                                     immutable: true}))
    end
    ret_val
  end

  def SoftwareServiceDefinition.service_environments(service_hash)
    retval = Array.new
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    if service_def != nil
      owner= []
      owner[0]= 'service_consumer'
      path = service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + ':'

      service_environment_variables = service_def[:target_environment_variables]
        STDERR.puts( 'service_variables' + service_environment_variables.to_s )
      service_variables = service_def[:consumer_params]
     # SystemDebug.debug(SystemDebug.services,:SERVICE_ENVIRONMENT_VARIABLES, service_environment_variables)
      unless service_environment_variables.nil?
        service_environment_variables.values.each do |env_variable_pair|
          env_name = env_variable_pair[:environment_variable_name]
          value_name = env_variable_pair[:variable_name]
          if env_name.nil?
            env_name = value_name
            STDERR.puts('Set env name to val name !')
          end
          next unless service_hash[:variables].key?(value_name.to_sym)
          value = service_hash[:variables][value_name.to_sym]
          owner[1] = path + value_name
          next unless service_variables.key?(value_name.to_sym)
          immutable = service_variables[value_name.to_sym][:immutable]
          build_time_only = service_variables[value_name.to_sym][:build_time_only]
          setatrun = service_variables[value_name.to_sym][:ask_at_build_time]
          mandatory = service_variables[value_name.to_sym][:mandatory]
          retval.push(EnvironmentVariable.new({name: env_name, 
                                   value: value, 
                                   ask_at_build_time: setatrun, 
                                   mandatory: mandatory, 
                                   label: value_name,
                                   build_time_only: build_time_only, 
                                   owner_path: owner,
                                   owner_type: service_hash[:container_type],
                                   immutable: immutable}))       
        end                                                     
      end
    else
      raise EnginesException.new(self.error_hash('Failed to load service definition', service_hash))
    end
   # SystemDebug.debug(SystemDebug.builder, :COMPLETE_SERVICE_ENVS, retval)
    retval

  end

  def SoftwareServiceDefinition.find(service_type, provider)
    raise EnginesException.new(self.error_hash('Missing params :provider or :service_type' + provider.to_s + ':' + service_type.to_s, provider))  if service_type == nil || provider == nil

    dir = SystemConfig.ServiceTemplateDir + '/' + provider
    if Dir.exist?(dir)
      service_def = SoftwareServiceDefinition.load_service_def(dir, service_type)
      if service_def == nil
        raise EnginesException.new(self.error_hash('No matching Service', provider.to_s + '/' + service_type.to_s ))
      end
      service_def #.to_h
    else
      raise EnginesException.new(self.error_hash('No Dir', dir.to_s + ':'  + service_type.to_s + ':'+ provider.to_s ))
    end
  end

  def SoftwareServiceDefinition.load_service_def(dir, service_type)
    service_name = File.basename(service_type)
    filename = dir + '/' + service_type + '/' + service_name + '.yaml'
    if File.exist?(filename)
      yaml = File.read(filename)
      SoftwareServiceDefinition.from_yaml(yaml)
    else
      raise EnginesException.new(self.error_hash('No Such Definitions File!' + dir.to_s + '/' + service_type.to_s + ' ' + filename.to_s))
    end
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
            load(dir, service_type)
            break
          end
        end
      end
    end
  end

  def SoftwareServiceDefinition.is_persistent?(params)
    service = SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
    if service == nil
      nil
    elsif service.key?(:persistent)
      service[:persistent]
    else
      false
    end
  end

  def SoftwareServiceDefinition.is_sharable?(params)
    STDERR.puts(' Check sharable on ' + params.to_s)
    service = SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
    if service == nil
      nil
    elsif service.key?(:shareable)
      STDERR.puts(' sharable val' +  service[:shareable].to_s) 
      service[:shareable]
    else
      # default is sharable
      STDERR.puts(' It is sharable ' + params.to_s)
      true
    end
  end
def SoftwareServiceDefinition.is_consumer_exportable?(params)
  service = SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace])
  if service == nil
    nil
  elsif service.key?(:consumer_exportable)
    service[:consumer_exportable]
  else
    # default is consumer_exportable
    true
  end
end
  def SoftwareServiceDefinition.is_soft_service?(service_hash)
    service = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    if service.key?(:soft_service)
      service_hash[:soft_service] = service[:soft_service]
      service[:soft_service]
    else
      false
    end
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