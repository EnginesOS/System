module EnginesCoreSystem
  def api_shutdown
    SystemDebug.debug(SystemDebug.system,  :BEING_SHUTDOWN)
    @registry_handler.api_shutdown
  end

  def dump_heap_stats
    ObjectSpace.garbage_collect
    file = File.open("/engines/var/run/heap.dump", 'w')
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
    ports = []
    ports.push(443)
    ports.push(8484)
    ports.push(80)
    ports.push(22)
    ports.push(808)
    ports
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