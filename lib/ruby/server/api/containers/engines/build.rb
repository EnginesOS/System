post '/v0/containers/engines/build' do

  r = @@core_api.build_engine(Utils.symbolize_keys(params))
  
  return log_error('build engine', params) if r.is_a?(FalseClass)
  r.to_json
end