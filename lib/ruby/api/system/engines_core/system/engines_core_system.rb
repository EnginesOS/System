module EnginesCoreSystem
  def api_shutdown
   # SystemDebug.debug(SystemDebug.system,  :BEING_SHUTDOWN)
    service_manager.api_shutdown
  end

  def dump_heap_stats
    ObjectSpace.garbage_collect
    file = File.open("/home/engines/run/heap.dump", 'w')
    begin
      ObjectSpace.dump_all(output: file)
    ensure
      file.close
    end
    true
  end

  def set_first_run_parameters(params_from_gui)
    require '/opt/engines/lib/ruby/first_run_wizard/first_run_wizard.rb'
    params = params_from_gui.dup
    #SystemDebug.debug(SystemDebug.first_run,params)
    first_run = FirstRunWizard.new(params)
    first_run.apply
    first_run.sucess
  end

  def reserved_engine_names
    names = list_managed_engines
    names.concat(list_managed_services)
    names.concat(list_system_services)
    names
  end

  def reserved_ports
    @reserved_ports |= [443, 8484, 80, 22, 808]
    @reserved_ports
  end

  def registered_ports
    unless @registered_ports.is_a?(Hash)
      @registered_ports = {}
      containers = getManagedEngines.concat(getManagedServices).concat(getSystemServices)
      containers.each do | c |
        next unless c.is_active?
        next unless c.mapped_ports.is_a?(Hash)
        c.mapped_ports.each_value do |  p|
          # STDERR.puts('Registered:' + p.to_s + ' to ' + c.container_name)
          @registered_ports[c.container_name] = p[:external]
        end
      end
    end
    @registered_ports
  end

  def is_port_available?(port)
    registered_ports.each_pair do | c , p|
      next if p.nil?
      #  STDERR.puts('Check ' + port.to_s + ' with ' + p.to_s)
      return c if p == port
    end
    true
  end

  def register_port(container_name, port)
    registered_ports[container_name] = port
  end

  def deregister_port(container_name, port)
    # STDERR.puts('de reg port ' + container_name.to_s + ':' + port.to_s)
    registered_ports.delete(container_name)
  end

  def get_disk_statistics
    'belum'
  end

  def first_run_required?
    require '/opt/engines/lib/ruby/first_run_wizard/first_run_wizard.rb'
    FirstRunWizard.required?
  end

  def container_memory_stats(engine)
    MemoryStatistics.container_memory_stats(engine)
  end

end