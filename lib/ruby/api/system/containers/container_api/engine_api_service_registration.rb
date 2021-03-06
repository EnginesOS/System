class ContainerApi
  def register_with_dns(container)
    if container.conf_register_dns == true
      service_hash = create_dns_service_hash(container)
      begin
       # STDERR.puts('DNS REG' + service_hash.to_s)
        core.create_and_register_service(service_hash)
      end
    end
  end

  def deregister_with_dns(container)
    if container.conf_register_dns == true
      service_hash = create_dns_service_hash(container)
      core.dettach_service(service_hash)
    end
  end

  def deregister_with_zeroconf(container)
    if container.conf_register_dns == true
      service_hash = create_zeroconf_service_hash(container)
      begin
        core.dettach_service(service_hash)
      rescue
      end
    end
  end

  def register_with_zeroconf(container)
    if container.conf_register_dns == true
      service_hash = create_zeroconf_service_hash(container)
      begin
        core.create_and_register_service(service_hash)
      rescue
      end
    end
  end

  # Called by Managed Containers
  def register_non_persistent_services(engine)
    core.register_non_persistent_services(engine)
  end

  # Called by Managed Containers
  def deregister_non_persistent_services(engine)
    core.deregister_non_persistent_services(engine)
  end

  def remove_wap_service(container)
    service_hash = create_wap_service_hash(container)
    # STDERR.puts('remove ' + service_hash.to_s)
    core.dettach_service(service_hash)
  end

  def add_wap_service(container)
    service_hash = create_wap_service_hash(container)
    core.create_and_register_service(service_hash)
  rescue StandardError => e
    STDERR.puts('Add Wap Exception ' + e.to_s)
    # sometimes duplicates nginx record
  end

  def engine_persistent_services(container)
    if container.ctype != 'service'
      core.engine_persistent_services(container.container_name)
    else
      core.service_persistent_services(container.container_name)
    end
  end

end
