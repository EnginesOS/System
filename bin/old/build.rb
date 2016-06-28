#!/home/engines/.rbenv/versions/2.1.3/bin/ruby


require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require "/opt/engines/lib/ruby/system/SysConfig.rb"
require "/opt/engines/lib/ruby/containers/ManagedEngine.rb"
require "/opt/engines/lib/ruby/api/public/EnginesOSapi.rb"
require "/opt/engines/lib/ruby/api/public/EnginesOSapiResult.rb"
require "securerandom"

def build_engine params
  engines_api = EnginesOSapi.new()
  core_api = engines_api.core_api

  @core_api = core_api
  builder = EngineBuilder.new(params, @core_api)
  builder.get_blueprint_from_repo 
  engine = builder.build_container

end

params=Hash.new

params[:engine_name] = ARGV[0]
params[:domain_name] = ARGV[3]
params[:host_name] = ARGV[2]
params[:http_protocol] = ARGV[1]
params[:repository_url] =ARGV[4]
params[:software_environment_variables]=nil

build_engine params
