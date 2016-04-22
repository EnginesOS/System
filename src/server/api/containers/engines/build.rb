post '/v0/containers/engines/build' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
  r = @@core_api.build_engine(cparams)
  
  return log_error('build engine', params) if r.is_a?(FalseClass)
  r.to_json
end