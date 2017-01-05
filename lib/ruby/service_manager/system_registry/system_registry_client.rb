class SystemRegistryClient < ErrorsApi
  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown

  end
  require_relative 'api/xcon_rset.rb'
  #  require_relative 'xcon_rset.rb'
  require_relative 'api/configurations.rb'
  require_relative 'api/services.rb'
  require_relative 'api/engines.rb'
  require_relative 'api/registry.rb'
  require_relative 'api/orphans.rb'
  require_relative 'api/subservices.rb'
  require_relative 'api/shares.rb'
  require_relative 'engines_registry_client_errors.rb'
  require_relative 'engines_registry_error.rb'
  
  include EnginesRegistryClientErrors
  include Configurations
  include Services
  include Engines
  include Orphans
  include Registry
  include Subservices
  include Shares
 def get_registry()
   system_registry_tree
 end
 
end
