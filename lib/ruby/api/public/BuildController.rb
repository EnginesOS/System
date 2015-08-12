class BuildController
  
  
  def initialize(api)
    @core_api = api 
    @last_error = nil
    @build_log_stream = nil
    @build_error_stream = nil
  end
  
  attr_accessor :last_error
    
  def get_engine_builder(params)
    builder = EngineBuilder.new(params, @core_api)
 
    return builder  
  end
  
 def close_streams
   @build_log_stream = nil
      @build_error_stream = nil
 end
 
  def get_engine_builder(_bfrrepository,host,domain_name,environment)
    builder = EngineBuilder.new(repository,host,domain_name,environment)
    @build_log_stream = builder.get_build_log_stream
      @build_error_stream = builder.get_build_err_stream
      return builder  
  end
  
  def build_engine(params)
  p :builder_params
    p params

    engine_builder = get_engine_builder(params)
    engine = engine_builder.build_from_blue_print
    if engine == false
      @last_error = engine_builder.last_error
      return  false
    end
    if engine != nil
      return engine
    end
    @last_error = engine_builder.last_error
    return false

  rescue Exception=>e
      if engine_builder.is_a?(EngineBuilder) 
          @last_error = engine_builder.last_error
      end
      @last_error= @last_error.to_s + ":Exception:" + e.to_s + ":" + e.backtrace.to_s
    return false
  end

  def get_engine_builder_streams
    
      return  ([@build_log_stream,   @build_error_stream])
 
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = get_engine_builder_bfr(repository,host,domain_name,environment)
    engine = engine_builder.build_from_blue_print
    if engine == false
      @last_error= @last_error.to_s + ":Exception:" + e.to_s + ":" + e.backtrace.to_s
    return false      
    end
    if engine != nil
      engine.save_state
      return engine
    end
    @last_error= @last_error.to_s + ":Exception:" + e.to_s + ":" + e.backtrace.to_s    
    return false     

    rescue Exception=>e
        if engine_builder.is_a?(EngineBuilder) 
            @last_error = engine_builder.last_error
        end
        @last_error= @last_error.to_s + ":Exception:" + e.to_s + ":" + e.backtrace.to_s
      return false
    end
    
 

  
end