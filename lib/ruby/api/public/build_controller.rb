module BuildController
  def build_engine(params)

    p params

    @engine_builder = EngineBuilder.new(params, @core_api)
    engine = @engine_builder.build_from_blue_print
    if engine == false
      return  failed(params[:engine_name],@engine_builder.last_error,"build_engine")
    end
    if engine != nil
      if engine.is_active? == false
        return failed(params[:engine_name],"Failed to start  " + @engine_builder.last_error.to_s ,"build_engine")
      end
      return engine
    end
    return failed(host_name,@engine_builder.last_error,"build_engine")

  rescue Exception=>e
    return log_exception_and_fail("build_engine",e)
  end

  def get_engine_builder_streams
    if @engine_builder != nil
      return  ([@engine_builder.get_build_log_stream,  @engine_builder.get_build_err_stream])
    end
    return nil
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,host,domain_name,environment, @core_api)
    engine = engine_builder.build_from_blue_print
    if engine == false
      return  failed(host,last_api_error,"build_engine")
    end
    if engine != nil
      engine.save_state
      return engine
    end
    return  failed(host,last_api_error,"build_engine")

  rescue Exception=>e
    return log_exception_and_fail("buildEngine",e)
  end

  def get_engine_build_report(engine_name)
    return   @core_api.get_build_report(engine_name)
  end

  def rebuild_engine_container engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Load Engine Blueprint")
    end
    state = engine.read_state
    if state == "running" || state == "paused"
      return failed(engine_name,"Cannot rebuild a container in State:" + state,"Rebuild Engine")
    end
    retval = engine.rebuild_container
    if retval.is_a?(ManagedEngine)
      success(engine_name,"Rebuild Engine Image")
    else
      puts "rebuild error"
      p engine.last_error
      return failed(engine_name,"Cannot rebuild Image:" + engine.last_error,"Rebuild Engine")

    end
  rescue Exception=>e
    return log_exception_and_fail("Rebuild Engine",e)
  end

  def build_engine_from_docker_image(params)

    return success(engine_name,"Build Engine from Docker Image")

  rescue Exception=>e
    return log_exception_and_fail("Build Engine from dockerimage",e)
  end
end