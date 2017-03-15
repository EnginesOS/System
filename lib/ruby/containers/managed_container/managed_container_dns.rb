module ManagedContainerDns
  # Register the dns
  # bootsrap service dns into ManagedService registry
  # would be better if it check a pre exisiting record will throw error on recreate
  #
  def register_with_dns # MUst register each time as IP Changes
    return false unless has_api?
    return true unless @conf_register_dns
    r = @container_api.register_with_dns(self)
    return r unless @conf_zero_conf
    return @container_api.register_with_zeroconf(self) if r
     r
  end
  def deregister_with_dns# MUst register each time as IP Changes
  return false unless has_api?
  return true unless @conf_register_dns
  r = @container_api.deregister_with_dns(self)
  return r unless @conf_zero_conf
  return @container_api.deregister_with_zeroconf(self) if r
   r
end
  def fqdn
    return 'N/A' if @domain_name.nil? == true
     @hostname.to_s + '.' + @domain_name.to_s
  end

  def set_hostname_details(host_name, domain_name)
    @hostname = host_name
    @domain_name = domain_name
     true
  end
  
  def domain_name
    @domain_name = SystemConfig.internal_domain if @domain_name.nil?
      @domain_name
  end

end