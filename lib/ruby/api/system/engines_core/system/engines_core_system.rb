module EnginesCoreSystem
  def api_shutdown
    SystemDebug.debug(SystemDebug.system,  :BEING_SHUTDOWN)
    @registry_handler.api_shutdown
  end

  def dump_heap_stats
    ObjectSpace.garbage_collect
    file = File.open("/home/engines/run/heap.dump", 'w')
    ObjectSpace.dump_all(output: file)
    file.close
    true
  end

  def set_first_run_parameters(params_from_gui)
    require_relative '../first_run_wizard/first_run_wizard.rb'
    params = params_from_gui.dup
    SystemDebug.debug(SystemDebug.first_run,params)
    first_run = FirstRunWizard.new(params)
    first_run.apply(self)
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
          containers.each do |c|
            next unless c.is_active?
            next unless c.mapped_ports.is_a?(Hash)
            c.mapped_ports.each_value do | p|
              @registered_ports[c.container_name] = p
            end            
          end
    end
    @registered_ports
  end

  def is_port_available?(port)
    registered_ports.each_pair do | c , p|
     return c if p = port
  end
     true
  end

  def register_port(container_name, port)
    registered_ports[container_name] = port
  end

  def deregister_port(container_name, port)
    registered_ports.delete(container_name)
  end

  def get_disk_statistics
    'belum'
  end

  def first_run_required?
    require_relative '../first_run_wizard/first_run_wizard.rb'
    FirstRunWizard.required?
  end

  def container_memory_stats(engine)
    MemoryStatistics.container_memory_stats(engine)
  end

  def get_timezone
    @system_api.get_timezone
  end

  def set_timezone(tz)
    @system_api.set_timezone(tz)
  end

  def shutdown(reason)
    # FIXME: @registry_handler.api_dissconnect
    @system_api.api_shutdown(reason)
  end
end