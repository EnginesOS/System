module PublicApiSystemDomains
  def add_domain(params)
    @core_api.add_domain(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def list_domains
    @core_api.list_domains
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_domain(params)
    @core_api.remove_domain(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def domain_name(params)
    @core_api.domain_name(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def update_domain(params)
    @core_api.update_domain(params)
  rescue StandardError => e
    handle_exception(e)
  end

end