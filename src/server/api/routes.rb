after do
  GC::OOB.run
end
require_relative 'auth/login.rb'
require_relative 'containers/routes.rb'
require_relative 'registry/registry.rb'
require_relative 'service_manager/routes.rb'
require_relative 'system/routes.rb'
require_relative 'engine_builder/engine_builder.rb'
require_relative 'backup/routes.rb'
require_relative 'unauthenticated/routes.rb'
require_relative 'missing_route_404.rb'
