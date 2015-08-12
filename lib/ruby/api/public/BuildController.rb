class BuildController
  
  
  def initialize(api)
    @core_api = api 
    @last_error = nil
  end
  
  attr_accessor :last_error
    
  
  def build_engine(params)
  p :builder_params
    p params

    engine_builder = EngineBuilder.new(params, @core_api)
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
    if @engine_builder != nil
      return  ([@engine_builder.get_build_log_stream,  @engine_builder.get_build_err_stream])
    end
    return nil
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,host,domain_name,environment, @core_api)
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