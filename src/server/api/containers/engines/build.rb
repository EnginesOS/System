post '/v0/containers/engines/build' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
  r = @@engines_api.build_engine(cparams)
  
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  r.to_json
end