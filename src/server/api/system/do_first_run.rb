# @!group /system/do_first_run/
# @method do_first_run
# @overload post '/v0/system/do_first_run'
# apply first run params
# @param :admin_password
# @param :admin_email
# @param :system_hostname
# @param :networking
# @param :domain_name
# @param :self_dns_local_only
# @param :ssl_person_name
# @param :ssl_organisation_name
# @param :ssl_city
# @param:ssl_state
# @param :ssl_country
# @param :networking  dynamic_dns|zeroconf|self_hosted_dns|external_dns
# @param :dynamic_dns_provider when :networking = dynamic_dns
# @param :dynamic_dns_username when :networking = dynamic_dns
# @param :dynamic_dns_password when :networking = dynamic_dns
# @return [true]
post '/v0/system/do_first_run' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    r = engines_api.set_first_run_parameters(cparams)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
