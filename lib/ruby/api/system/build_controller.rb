class BuildController
  require '/opt/engines/lib/ruby/engine_builder/engine_builder.rb'
  attr_reader :engine,
  :build_error,
  :build_params,
  :engine,
  :engine_builder

  def initialize(api)
    @core_api = api
    @engine = nil
    @build_error = 'none'
    @engine_builder = nil
  end

  def build_from_docker(params)
  end

  def abort_build
    SystemDebug.debug(SystemDebug.builder, :abort_build)

    @core_api.abort_build 
  end
  
  def build_engine(params)
    SystemDebug.debug(SystemDebug.builder, :builder_params, params)
    r = '' 
 
    @build_params = params
    SystemStatus.build_starting(@build_params)
    @engine_builder = get_engine_builder(@build_params)
    return  @engine_builder if  @engine_builder.is_a?(EnginesError)
    return build_failed(params, r) if (r = @engine_builder.check_build_params(params)).is_a?(EnginesError)
   
    @engine = @engine_builder.build_from_blue_print
    
    @build_error = @engine_builder.last_error
    SystemDebug.debug(SystemDebug.builder, :build_error,  @engine_builder.build_error.to_s) unless  @engine_builder.build_error.nil?
    
    build_failed(params, @build_error) if @engine.nil? || @engine.is_a?(EnginesError)
    build_failed(params, @build_error) unless @engine.is_a?(ManagedEngine)
     build_complete(@build_params)
    
  rescue StandardError => e
    build_failed(params, e.to_s)
  end



  def buildEngine(repository, host, domain_name, environment)
    @build_params = {}
    @build_params[:repository] = repository
    @build_params[:host] = host
    @build_params[:domain_name] = domain_name

    SystemStatus.build_starting(@build_params)
    @engine_builder= get_engine_builder_bfr(repository, host, domain_name, environment)
    return  @engine_builder if  @engine_builder.is_a?(EnginesError)
    @engine = @engine_builder.build_from_blue_print
    @build_error = @engine_builder.last_error
    return build_failed(@build_params, @build_error)  unless engine.is_a(ManagedEngine)
    @engine.save_state
    build_complete(@build_params)
     @engine
  rescue StandardError => e
    build_failed(@build_params, e)
  end

 

  def reinstall_engine(engine)
    @build_params = {}
    @build_params[:engine_name] = engine.container_name
    @build_params[:domain_name] = engine.domain_name
    @build_params[:host_name] = engine.hostname
    @build_params[:software_environment_variables] = engine.environments
    @build_params[:http_protocol] = engine.protocol
    @build_params[:memory] = engine.memory
    @build_params[:repository_url] = engine.repository
    @build_params[:variables]  = engine.environments
    @build_params[:reinstall] = true
    SystemStatus.build_starting(@build_params)
    SystemDebug.debug(SystemDebug.builder,  ' Starting resinstall with params ', @build_params)
    @engine_builder = get_engine_builder(@build_params)
    return build_failed(params, 'No Builder') unless @engine_builder.is_a?(EngineBuilder)
    @engine = @engine_builder.build_from_blue_print
    @build_error = @engine_builder.last_error
    return build_failed(@build_params, @build_error) unless @engine.is_a?(ManagedEngine)
    return build_failed(@build_params, @build_error) unless @engine.is_active?
      build_complete(@build_params)
   # return @engine
  rescue StandardError => e
    build_failed(@build_params, e)
    SystemUtils.log_exception(e)
  end

  private

  def get_engine_builder(params)
    @engine_builder = EngineBuilder.new(params, @core_api)
    @engine_builder.setup_build

  end


  def get_engine_builder_bfr(repository, host, domain_name, environment)
    @build_params = {}
    @build_params[:repository] = repository
    @build_params[:host_name] = host
    @build_params[:domain_name] = domain_name
    @build_params[:environment] = environment
    get_engine_builder(@build_params)
    @engine_builder.setup_build
 
  end

  def build_failed(params,err)
   
    params[:error] = err.to_s
    @build_error = err
    @core_api.build_stoped()   
    SystemUtils.log_error_mesg(err.to_s, params)
    
    Thread.new{  SystemStatus.build_failed(params) }
      
   return err if err.is_a?(EnginesError)
     EnginesError.new(params[:engine_name] +  err.to_s + params.to_s , :build_error)
  end
  
  def build_complete(build_params)
    SystemStatus.build_complete(build_params)    
    @core_api.build_stoped()
    true
  end
end
