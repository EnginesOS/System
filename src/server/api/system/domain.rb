# @!group /system/domain/

# @method get_domain_name
# @overload get '/v0/system/domain/:domain_name'
# get the details for :domain_name
# @return  [Hash] :domain_name :self_hosted :internal_only
# test cd /opt/engines/tests/engines_api/system/domains ; make view
get '/v0/system/domain/:domain_name' do
  begin
    return_json(engines_api.domain_name(params[:domain_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method update_domain_name
# @overload post '/v0/system/domain/:domain_name'
# update the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
#test cd /opt/engines/tests/engines_api/system/domains ; make update
post '/v0/system/domain/:domain_name' do
  begin
    post_s = post_params(request)
    post_s[:domain_name] = params['domain_name']
    cparams = assemble_params(post_s, [:domain_name], :all)
      STDERR.puts('DNS PARA ' + cparams.to_s)
    return_boolean(engines_api.update_domain(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
