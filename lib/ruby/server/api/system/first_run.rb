
  
  #/system/do_first_run P

post '/v0/system/do_first_run' do

  unless @@core_api.set_first_run_parameters(params).is_a?(FalseClass)
    return status(202)
  else
    return log_error('set_first_run_parameters', params)
  end
end