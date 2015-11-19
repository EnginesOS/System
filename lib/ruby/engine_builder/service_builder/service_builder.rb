require_relative '../../service_manager/service_definitions.rb'
class ServiceBuilder < ErrorsApi
  
  attr_reader :volumes,:app_is_persistant
  
  require_relative 'orphan_service_builder.rb'
  include OrphansServiceBuilder
  require_relative 'local_file_service_builder.rb'
  include LocalFileServiceBuilder
  require_relative 'service_roll_back.rb'
  include ServiceRollBack
  require_relative 'service_checks.rb'
  include ServiceChecks
  require_relative 'persistant_service_builder.rb'
  include PersistantServiceBuilder
    
  def initialize(core_api, templater, engine_name, attached_services)
    @engine_name = engine_name
    @core_api = core_api
    @templater = templater
    @attached_services =  attached_services 
    @volumes = {}
    @orphans = []
    @app_is_persistant = false
      p @engine_name 
  end
    
  def create_non_persistant_services(services)  
  services.each do |service_hash|
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
    next if service_def[:persistant]
    service_hash = ServiceDefinitions.set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg('Failed to Attach ', service_hash) unless @core_api.add_service(service_hash)
    @attached_services.push(service_hash)
  end
  return true
end


 
 
#  def get_service_def(service_hash)
#    p service_hash[:type_path]
#    p service_hash[:publisher_namespace]
#    return SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
#  end


  
end
