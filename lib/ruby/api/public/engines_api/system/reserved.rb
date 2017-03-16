module PublicApiSystemReserved
  def reserved_engine_names
    names = list_managed_engines
    names.concat(list_managed_services)
    names.concat(list_system_services)
    names
  rescue StandardError => e
    handle_exception(e)
  end

  def taken_hostnames
    @core_api.taken_hostnames
  rescue StandardError => e
    handle_exception(e)
  end

  def list_system_services
    services = []
    services.push('registry')
    services
  rescue StandardError => e
    handle_exception(e)
  end

  # FIXME should use System
  def reserved_ports
    ports = []
    ports.push(443)
    ports.push(10443)
    ports.push(80)
    ports.push(22)
    ports.push(808)
    ports
  rescue StandardError => e
    handle_exception(e)
  end
end