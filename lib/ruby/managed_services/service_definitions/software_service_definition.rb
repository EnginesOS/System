require 'json'

class SoftwareServiceDefinition
  attr_reader :accepts,
  :author,
  :title,
  :description,
  :service_name,
  :consumer_params,
  :setup_params,
  :dedicated,
  :service_type,
  :publisher_namespace,
  :service_container,
  :persistant,
  :target_environment_variables,
  :service_handle_field
  def SoftwareServiceDefinition.from_yaml( yaml )
    begin
      # p yaml.path
      serviceDefinition = YAML::load( yaml )
      return serviceDefinition
    rescue Exception=>e
      SystemUtils.log_error_mesg('Problem loading Yaml',yaml)
      SystemUtils.log_exception(e)
    end
  end

  #Find the assigned service container_name from teh service definition file
  def SoftwareServiceDefinition.get_software_service_container_name(params)
 
    server_service =  self.software_service_definition(params)
    return  SystemUtils.log_error_mesg('Failed to load service definitions',params) if server_service.nil? || server_service == false
 
    return server_service[:service_container]   
    rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
  def SoftwareServiceDefinition.service_environments(service_hash)
    retval = Array.new
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
        if  service_def != nil
          service_environment_variables = service_def[:target_environment_variables]
#            p service_environment_variables.to_s
           if service_environment_variables != nil
             service_environment_variables.values.each do |env_variable_pair|
               env_name = env_variable_pair[:environment_name]
               value_name = env_variable_pair[:variable_name]
#                 p :hunting 
#                 p env_variable_pair[:variable_name]
               value=service_hash[:variables][value_name.to_sym]
#               p service_hash
#               p env_variable_pair
             retval.push( EnvironmentVariable.new(env_name,value,false,true,false,service_hash[:type_path] + env_name,false)) # env_name , value
             end                                                      #(name,value,setatrun,mandatory,build_time_only,label,immutable)
        end
  else
    SystemUtils.log_error_mesg('Failed to load service definition',service_hash)
  end
     return retval
  
  end
  def SoftwareServiceDefinition.find(service_type,provider)
    if service_type == nil  || provider == nil
      return nil
    end
    dir = SystemConfig.ServiceTemplateDir + '/' + provider
    if Dir.exist?(dir)
      service_def = SoftwareServiceDefinition.load_service_def(dir,service_type)
      if service_def == nil
        SystemUtils.log_error_mesg('Nil Service type',provider.to_s + '/' + service_type.to_s )
        return nil
      end
      return service_def.to_h
    end
    SystemUtils.log_error_mesg('No Dir',dir)
    return nil
  rescue Exception=>e
    SystemUtils.log_error_mesg('Error ' ,provider.to_s + '/' + service_type.to_s )
    SystemUtils.log_exception(e)
    return nil
  end

  def SoftwareServiceDefinition.load_service_def(dir,service_type)
    filename=dir + '/' + service_type + '.yaml'
    if File.exist?(filename)
      yaml = File.read(filename)
      return SoftwareServiceDefinition.from_yaml(yaml)
    end
    SystemUtils.log_error_mesg('No Such Definitions File',dir.to_s + '/' + service_type.to_s)
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
          if File.exist?(root + '/' + service_dir_entry + '/' + service_type + '.yaml' )
            return load(dir,service_type)
          end
        end
      end
    end
  rescue Exception=>e
    SystemUtils.log_exception(e)
  end

  def SoftwareServiceDefinition.is_persistant?(params)
    service =  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace])
    if service == nil
      return nil
    end
    return service[:persistant]
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