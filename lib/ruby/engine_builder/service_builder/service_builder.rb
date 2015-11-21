require_relative '../../service_manager/service_definitions.rb'

class ServiceBuilder < ErrorsApi

  attr_reader :volumes, :app_is_persistant

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
  require_relative 'non_persistant_service_builder.rb'
  include NonPersistantServiceBuilder
  def initialize(core_api, templater, engine_name, attached_services)
    @engine_name = engine_name
    @core_api = core_api
    @templater = templater
    @attached_services =  attached_services
    @volumes = {}
    @orphans = []
    @app_is_persistant = false
  end

end
