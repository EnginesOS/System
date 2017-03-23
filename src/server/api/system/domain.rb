# @!group /system/domains/
# @method get_domain_name
# @overload get '/v0/system/domains/:domain_name'
# get the details for :domain_name
# @return  [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/:domain_name' do
  begin
    domain_name = engines_api.domain_name(params[:domain_name])
    return_json(domain_name)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method update_domain_name
# @overload post '/v0/system/domains/:domain_name'
# update the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
post '/v0/system/domains/:domain_name' do
  begin
    post_s = post_params(request)
    post_s[:domain_name] = params['domain_name']
    cparams = assemble_params(post_s, [:domain_name], :all)
    r = engines_api.update_domain(cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
