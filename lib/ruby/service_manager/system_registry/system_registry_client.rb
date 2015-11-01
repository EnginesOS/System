class SystemRegistryClient < ErrorsApi
  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown

  end

#  require_relative 'rset.rb'
  require_relative 'configurations.rb'
  require_relative 'services.rb'
  require_relative 'engines.rb'
  require_relative 'registry.rb'
  require_relative 'orphans.rb'
  
  include Configurations
  include Services 
  include Engines
  include Oprhans
  include Registry 

end
