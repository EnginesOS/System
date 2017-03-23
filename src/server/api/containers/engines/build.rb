# @!group /containers/engines/
# @method build_engine
# @overload post '/v0/containers/engines/build'
# start app build process
#   :create_type in  :attached_services is active|orphan|new
# @param :engine_name a-z,0-9
# @param :memory integer
# @param :repository_url
# @param :variables Hash :name,value
# @param :reinstall true|false
# @param :web_port integer
# @param :host_name a-z,0-9
# @param :domain_name a-z,.,0-9
# @param :attached_services Array of Hash :publisher_namespace :type_path :create_type :parent_engine :service_handle
# @return [true]
post '/v0/containers/engines/build' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    r = engines_api.build_engine(cparams)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup