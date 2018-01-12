#require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'

class ServiceBuilder < ErrorsApi

  attr_reader :volumes, :app_is_persistent, :attached_services, :default_vol

  require_relative 'orphan_service_builder.rb'
  include OrphansServiceBuilder
  require_relative 'local_file_service_builder.rb'
  include LocalFileServiceBuilder
  require_relative 'service_roll_back.rb'
  include ServiceRollBack
  require_relative 'service_checks.rb'
  include ServiceChecks
  require_relative 'persistent_service_builder.rb'
  include PersistantServiceBuilder
  require_relative 'non_persistent_service_builder.rb'
  include NonPersistantServiceBuilder
  require_relative 'service_builder_errors.rb'
  include ServiceBuilderErrors
  def initialize(core_api, templater, engine_name, attached_services, basedir)
    @engine_name = engine_name
    @basedir = basedir
    @core_api = core_api
    @templater = templater
    @attached_services =  attached_services
    @volumes = {}
    @orphans = []
    @app_is_persistent = false
  end

  def service_resource(service_name, what)
    @core_api.service_resource(service_name, what)
  end

end
