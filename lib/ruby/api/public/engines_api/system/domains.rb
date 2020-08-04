class PublicApi 
  def add_domain(params)
    core.add_domain(params)
    true
  end

  def list_domains
    core.list_domains
  end

  def remove_domain(params)
    core.remove_domain(params)
    true
  end

  def domain_name(params)
    core.domain_name(params)
  end

  def update_domain(params)
   core.update_domain(params)
    true
  end

end
