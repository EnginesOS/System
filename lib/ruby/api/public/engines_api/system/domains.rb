module PublicApiSystemDomains
  def add_domain(params)
    @core_api.add_domain(params)
    true
  end

  def list_domains
    @core_api.list_domains
  end

  def remove_domain(params)
    @core_api.remove_domain(params)    
    true  
  end

  def domain_name(params)
    @core_api.domain_name(params)
  end

  def update_domain(params)
   @core_api.update_domain(params)
    true
  end

end