require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "/opt/engines/lib/ruby/ManagedEngine.rb"
require "/opt/engines/lib/ruby/EnginesOSapi.rb"
require "/opt/engines/lib/ruby/EnginesOSapiResult.rb"

  def build_engine params
    engines_api = EnginesOSapi.new()
    core_api = engines_api.core_api
  
  @core_api = core_api
  builder = EngineBuilder.new(params, @core_api)
  
  end

params=Hash.new
 params[:engine_name] = ARGV[1]
 params[:domain_name] = ARGV[4]
 params[:host_name] = ARGV[3]
 params[:http_protocol] = ARGV[2]
 params[:repository_url] =ARGV[5]
   
build_engine params
   