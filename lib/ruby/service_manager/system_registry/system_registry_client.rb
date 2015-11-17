class SystemRegistryClient < ErrorsApi
  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown

  end

#  require_relative 'rset.rb'
  require_relative 'api/configurations.rb'
  require_relative 'api/services.rb'
  require_relative 'api/engines.rb'
  require_relative 'api/registry.rb'
  require_relative 'api/orphans.rb'
  require_relative 'api/subservices.rb'
  
  include Configurations
  include Services 
  include Engines
  include Orphans
  include Registry 
  include Subservices 
  
end
