
# @!group /system/do_first_run/
# @method do_first_run
# @overload post '/v0/system/do_first_run'
# apply first run params
#   :admin_password  :admin_email :system_hostname :networking :domain_name :self_dns_local_only :ssl_person_name  :ssl_organisation_name  :ssl_city  :ssl_state  :ssl_country
#   :networking = 'dynamic_dns'|'zeroconf'|'self_hosted_dns'|'external_dns'
#   when :networking = 'dynamic_dns' 
#   :dynamic_dns_provider  :dynamic_dns_username :dynamic_dns_password
# @return [true]
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