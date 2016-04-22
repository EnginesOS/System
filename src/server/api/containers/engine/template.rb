#/containers/engine/container_name/template

post '/v0/containers/engine/:engine_name/template' do
  engine = get_engine(params[:engine_name])
  cparams =  Utils::Params.assemble_params(params, [:engine_name], :string)
  resolved_string = @@core_api.get_resolved_engine_string(cparams[:string],engine)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end