#/system/template/env P

post '/v0/system/template' do
 # engine = get_engine(params[:engine_name])
  cparams =  Utils::Params.assemble_params(params, [],  :string) 
  resolved_string = @@core_api.get_resolved_string(cparams[:string])
  return log_error('resolved_string', cparams) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json

end