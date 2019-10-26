class SystemRegistryClient < ErrorsApi
  class << self
    def instance
      @@instance ||= self.new
    end
  end
  def initialize
    @route_prefix = '/v0/system_registry/'
  end

  def api_shutdown
    close_connection
  end

  require_relative 'api/xcon_rest.rb'
  include XconRest
  
  require_relative 'api/configurations.rb'
  include Configurations
  require_relative 'api/services.rb'
  include Services
  require_relative 'api/engines.rb'
  include Engines
  require_relative 'api/registry.rb'
  include Registry
  require_relative 'api/orphans.rb'
  include Orphans
  require_relative 'api/subservices.rb'
  include Subservices
  require_relative 'api/shares.rb'
  include Shares  
  require_relative 'errors/engines_registry_client_errors.rb'
  include EnginesRegistryClientErrors

  require_relative 'errors/engines_registry_error.rb'
  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'

  def registry_root()
    system_registry_tree
  end

  protected
  
  def address_params(hash, param_symbols)
    r = ''
    param_symbols.each do | sym |
      break unless hash.key?(sym)
      r += '/' + hash[sym].to_s
    end
    SystemDebug.debug(SystemDebug.services, r.to_s)
    r
  end
  
  def core
    @core ||= EnginesCore.instance
  end
end
