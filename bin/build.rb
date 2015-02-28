#!/home/engines/.rbenv/versions/2.1.3/bin/ruby
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
 params[:engine_name] = ARGV[0]
 params[:domain_name] = ARGV[3]
 params[:host_name] = ARGV[2]
 params[:http_protocol] = ARGV[1]
 params[:repository_url] =ARGV[4]
   
build_engine params
   