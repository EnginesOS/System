# @!group /containers/engines/
# @method build_engine
# @overload post '/v0/containers/engines/build'
# start app build process
# @param :engine_name :memory :repository_url :variables :mapped_ports :reinstall :web_port :host_name :domain_name :attached_services
#   :engine_name :memory :repository_url :variables :mapped_ports :reinstall :web_port :host_name :domain_name :attached_services
# @return [true] 
post '/v0/containers/engines/build' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
  r = engines_api.build_engine(cparams)
  
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  r.to_json
end

# @!endgroup