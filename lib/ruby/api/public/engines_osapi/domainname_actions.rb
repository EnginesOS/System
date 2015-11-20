module DomainnameActions
  # @return String
  # get the default Domain used by the system in creating new engines and for services that use web
  def get_default_domain
    @core_api.get_default_domain
  end

  def update_domain(params)
    return success(params[:domain_name], 'update domain') if @core_api.update_domain(params)
    failed(params[:domain_name], last_api_error, 'update  domain')
  rescue StandardError => e
    log_exception_and_fail('update self hosted domain ' + params.to_s, e)
  end

  def add_domain(params)
    return success(params[:domain_name], 'Add domain') if @core_api.add_domain(params)
    failed(params[:domain_name], last_api_error, 'Add  domain')

  rescue StandardError => e
    log_exception_and_fail('Add self hosted domain ' + params.to_s, e)
  end

  def remove_domain(params)
    return success(params[:domain_name], 'Add domain') if @core_api.remove_domain(params)
    failed(params[:domain_name], last_api_error, 'Add  domain')
  rescue StandardError => e
    log_exception_and_fail('Add self hosted domain ' + params.to_s, e)
  end

  def list_domains
    res = DNSHosting.list_domains
    return res if res.is_a?(Hash)
    failed("Domains",res, 'list')
  rescue StandardError => e
    log_exception_and_fail('list domains ', e)
  end

end