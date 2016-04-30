#/system/do_first_run P

post '/v0/system/do_first_run' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = @@engines_api.set_first_run_parameters(cparams)
  unless r.is_a?(FalseClass)
    return status(202)
  else
    return log_error(request, r, @@engines_api.last_error)
  end
end