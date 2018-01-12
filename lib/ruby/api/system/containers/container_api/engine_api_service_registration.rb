module EngineApiServiceRegistration
  def register_with_dns(container)
    if container.conf_register_dns == true
      service_hash = create_dns_service_hash(container)
      begin
         STDERR.puts('DNS REG' + service_hash.to_s)
        engines_core.create_and_register_service(service_hash)
      end
    end
  end

  def deregister_with_dns(container)
    if container.conf_register_dns == true
      service_hash = create_dns_service_hash(container)
      engines_core.dettach_service(service_hash)
    end
  end

  def deregister_with_zeroconf(container)
    if container.conf_register_dns == true
      service_hash = create_zeroconf_service_hash(container)
      begin
        engines_core.dettach_service(service_hash)
      rescue
      end
    end
  end

  def register_with_zeroconf(container)
    if container.conf_register_dns == true
      service_hash = create_zeroconf_service_hash(container)
      begin
        engines_core.create_and_register_service(service_hash)
      rescue
      end
    end
  end

  # Called by Managed Containers
  def register_non_persistent_services(engine)
    engines_core.register_non_persistent_services(engine)
  end

  # Called by Managed Containers
  def deregister_non_persistent_services(engine)
    engines_core.deregister_non_persistent_services(engine)
  end

  def remove_nginx_service(container)
    service_hash = create_nginx_service_hash(container)
    # STDERR.puts('remove ' + service_hash.to_s)
    engines_core.dettach_service(service_hash)
  end

  def add_nginx_service(container)
    service_hash = create_nginx_service_hash(container)
    engines_core.create_and_register_service(service_hash)
  rescue
    # sometimes duplicates nginx record
  end

  def engine_persistent_services(container)
    if container.ctype != 'service'
      engines_core.engine_persistent_services(container.container_name)
    else
      engines_core.service_persistent_services(container.container_name)
    end
  end

end