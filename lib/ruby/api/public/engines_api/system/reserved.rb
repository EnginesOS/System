module PublicApiSystemReserved
  def reserved_engine_names
    names = list_managed_engines
    names.concat(list_managed_services)
    names.concat(list_system_services)
    names
  rescue StandardError => e
    SystemUtils.log_exception(e)
    failed('Gui', 'reserved_engine_names', 'failed')
    []
  end

  def taken_hostnames
    @core_api.taken_hostnames
  end

  def list_system_services
    services = []
    services.push('registry')
    services
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
  end
end