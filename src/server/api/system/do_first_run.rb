#/system/do_first_run P

post '/v0/system/do_first_run' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = engines_api.set_first_run_parameters(cparams)
  unless r.is_a?(EnginesError)
    status(202)
    r.to_json
  else
     log_error(request, r, engines_api.last_error)
  end
end