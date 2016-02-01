module EngineActions
  def list_apps
    @core_api.list_managed_engines
  rescue StandardError => e
    log_exception_and_fail('list_apps', e)
    return []
  end

  def getManagedEngines
    @core_api.getManagedEngines
  rescue StandardError => e
    log_exception_and_fail('getManagedEngines', e)
  end

  def loadManagedEngine(engine_name)
    engine = @core_api.loadManagedEngine(engine_name)
    return engine if engine.is_a?(ManagedEngine)
    failed(engine_name, last_api_error, 'Load Engine')
  rescue StandardError => e
    log_exception_and_fail('loadManagedEngine', e)
  end

  def recreateEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Stop') if engine.recreate_container
    failed(engine_name, 'No Engine', 'Stop')
  rescue StandardError => e
    log_exception_and_fail('recreateEngine', e)
  end

  def stopEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Stop') if engine.stop_container
    failed(engine_name, 'No Engine', 'Stop')
  rescue StandardError => e
    log_exception_and_fail('stopEngine', e)
  end

  def startEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Start') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Start') if engine.start_container
    failed(engine_name, engine.last_error, 'Start')
  rescue StandardError => e
    log_exception_and_fail('startEngine', e)
  end

  def pauseEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Pause') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Pause') if engine.pause_container
    failed(engine_name, engine.last_error, 'Pause')
  rescue StandardError => e
    log_exception_and_fail('startEngine', e)
  end

  def unpauseEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Unpause') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'unpause') if engine.unpause_container
    failed(engine_name, engine.last_error, 'Unpause')
  rescue StandardError => e
    return log_exception_and_fail('unpause', e)
  end

  def destroyEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Destroy') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Destroy') if engine.destroy_container
    failed(engine_name, engine.last_error, 'Destroy')
  rescue StandardError => e
    log_exception_and_fail('Destroy', e)
  end

  def deleteEngineImage(params)
    return failed(params.to_s, 'no Engine name', 'Delete') if params.key?(:engine_name) == false || params[:engine_name].nil?
    engine = loadManagedEngine(params[:engine_name])
    return failed(params[:engine_name], 'no Engine', 'Delete') if engine.is_a?(EnginesOSapiResult)
    return success(params[:engine_name], 'Delete') if @core_api.delete_engine(params)
    failed(params[:engine_name], last_api_error, 'Delete Image ')
  rescue StandardError => e
    log_exception_and_fail('Delete', e)
  end

  def reinstall_engine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)

    return success(engine_name, 'Re Installed') if @core_api.reinstall_engine(engine).is_a?(ManagedEngine)
    failed(engine_name, @core_api.last_error, 'Reinstall Engine Failed')
  end

  def createEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return engine if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Create') if engine.create_container
    failed(engine_name, engine.last_error, 'Create')
  rescue StandardError => e
    log_exception_and_fail('Create', e)
  end

  def restartEngine(engine_name)
    engine = loadManagedEngine(engine_name)
    return failed(engine_name, 'no Engine', 'Restart') if engine.is_a?(EnginesOSapiResult)
    return success(engine_name, 'Restart') if engine.restart_container
    failed(engine_name, engine.last_error, 'Restart')
  rescue StandardError => e
    log_exception_and_fail('Restart', e)
  end

  def get_engine_blueprint(engine_name)
    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult)
     # FIXME ONCE Gui is fixed
     # return failed(engine_name, 'no Engine', 'Load Engine Blueprint')
      return {}
    end
    retval = engine.load_blueprint
    if retval == false 
      return {} # FIXME ONCE Gui is fixed
     # return failed(engine_name, engine.last_error, 'Load Engine Blueprint')
    end
    return retval
  rescue StandardError => e
    log_exception_and_fail('Load Engine Blueprint', e)
  end

  def set_engine_runtime_properties(params)
    if @core_api.set_engine_runtime_properties(params)
      return success(params[:engine_name], 'update engine runtime params')
    end
    return failed(params[:engine_name], @core_api.last_error, 'update engine runtime params')
  rescue StandardError => e
    log_exception_and_fail('set_engine_runtime params ', e)
  end

  def set_engine_network_properties(params)
    engine = loadManagedEngine(params[:engine_name])
    return engine if engine.instance_of?(EnginesOSapiResult)
    return failed('set_engine_network_details', last_api_error, 'set_engine_network_details') if engine.nil?
    return success(params[:engine_name], 'Update network details') if @core_api.set_engine_network_properties(engine, params)
    failed('set_engine_network_details', last_api_error, 'set_engine_network_details')
  end

  def get_engine_memory_statistics(engine_name)
    engine = loadManagedEngine(engine_name)
    MemoryStatistics.container_memory_stats(engine)
  rescue StandardError => e
    log_exception_and_fail('Get Engine Memory Statistics', e)
  end
end