module EngineBuildActions
  # Build stuff
   def build_engine(params)
     build_controller = BuildController.new(@core_api)
     Thread.new { build_controller.build_engine(params) }
     engine = build_controller.engine
     return engine if engine.is_a?(EnginesOSapiResult)
     return failed(params[:engine_name], 'Failed to start  ' + build_controller.build_error, 'build_engine') unless !engine.nil? && engine.is_active?
     success(params[:engine_name], 'Build Engine')
   end
 
   def buildEngine(repository, host, domain_name, environment)
     build_controller = BuildController.new(@core_api)
     Thread.new {build_controller.buildEngine(repository, host, domain_name, environment)}
 #    engine = build_controller.engine
 #    return engine if engine.is_a?(EnginesOSapiResult)
 #    return failed(host.to_s, 'Failed to start  ' + engine.last_error.to_s, 'build_engine') unless engine.is_active?
     success(host.to_s + '.' + domain_name.to_s, 'Start of Build for Engine ' )
   end
def rebuild_engine_container(engine_name)
   engine = loadManagedEngine(engine_name)
   return failed(engine_name, 'no Engine', 'Load Engine Blueprint') if engine.is_a?(EnginesOSapiResult)
   state = engine.read_state
   return failed(engine_name, 'Cannot rebuild a container in State:' + state, 'Rebuild Engine') if state == 'running' || state == 'paused'
   retval = engine.rebuild_container
   return success(engine_name, 'Rebuild Engine Image') if retval.is_a?(ManagedEngine)
   failed(engine_name, 'Cannot rebuild Image:' + engine.last_error, 'Rebuild Engine')
 rescue StandardError => e
   log_exception_and_fail('Rebuild Engine', e)
 end

 def build_engine_from_docker_image(params)
   p params[:host_name]
   build_controller = BuildController.new(@core_api)
   build_controller.build_from_docker(params)

   success(params[:host_name], 'Build Engine from Docker Image')
 rescue StandardError => e
   log_exception_and_fail('Build Engine from dockerimage', e)
 end

 def get_engine_build_report(engine_name)
   @core_api.get_build_report(engine_name)
 end
 
def current_build_params
return SystemStatus.current_build_params
end
def last_build_params
  SystemStatus.last_build_params
end
 
end