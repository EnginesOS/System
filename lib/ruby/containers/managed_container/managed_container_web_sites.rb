module ManagedContainerWebSites
  def set_deployment_type(deployment_type)
    @deployment_type = deployment_type
    remove_nginx_service if @deployment_type && @deployment_type != 'web'
    add_nginx_service if @deployment_type == 'web'
  end

  def web_sites
    @container_api.web_sites_for(self)
  end

  def http_protocol
    if @protocol.include?('_')
      @protocol.gsub(/_.*/,'')
    else
      @protocol.to_s
    end
  end

  def set_protocol(proto)
    case proto
    when 'HTTP and HTTPS'
      enable_http_and_https
    when 'HTTP only'
      enable_http_only
    when 'HTTPS only'
      enable_https_only
    else
      @protocol = proto.to_sym
    end
  end

  def enable_http_and_https
    @protocol = :http_and_https
  end

  def enable_https_only
    @protocol = :https_only
  end

  def enable_http_only
    @protocol = :http_only
  end

  # create nginx service_hash for container and register with nginx
  # @return boolean indicating sucess
  def add_nginx_service
    @container_api.add_nginx_service(self)
  end

  # create nginx service_hash for container deregister with nginx
  # @return boolean indicating sucess
  def remove_nginx_service
    @container_api.remove_nginx_service(self)
  end
end