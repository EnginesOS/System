class BuildController
  class << self
    def instance
      @@instance ||= self.new
    end
  end

  require '/opt/engines/lib/ruby/engine_builder/engine_builder.rb'
  attr_reader :engine,
  :build_error,
  :build_params

  def abort_build
    # SystemDebug.debug(SystemDebug.builder, :abort_build)
    core.abort_build
  end

  def prepare_engine_build(params)
    #SystemDebug.debug(SystemDebug.builder, :builder_params, params)
    @build_params = params
    SystemStatus.build_starting(@build_params)
    @engine_builder = get_engine_builder(@build_params)
    
  end

  def build_engine
    @engine = @engine_builder.build_from_blue_print
    #SystemDebug.debug(SystemDebug.builder, :build_error, @engine_builder.build_error.to_s) unless  @engine_builder.build_error.nil?
    build_complete
  end

  def buildEngine(repository, host, domain_name, environment)
    SystemStatus.build_starting(build_params)
    @build_params = {
      repository: repository,
      host_name: host,
      omain_name: domain_name,
      environment: environment
    }
    SystemStatus.build_starting(@build_params)
    @engine_builder= get_engine_builder_bfr(repository, host, domain_name, environment)
    @engine = @engine_builder.build_from_blue_print
    @engine.save_state
    build_complete(@build_params)
    @engine
  rescue StandardError =>e
    STDERR.puts("Got #{e} \n #{e.backtrace}")
  end

  def reinstall_engine(engine)
    @build_params = {
      engine_name: engine.container_name,
      domain_name: engine.domain_name,
      host_name: engine.hostname,
      software_environment_variables: engine.environments,
      http_protocol: engine.protocol,
      memory: engine.memory,
      repository_url: engine.container_name,
      variables: engine.environments,
      reinstall: true
    }
    SystemStatus.build_starting(@build_params)
   # SystemDebug.debug(SystemDebug.builder, 'Starting resinstall with params ', @build_params)
    @engine_builder = get_engine_builder(@build_params)
    if @engine_builder.is_a?(EngineBuilder)
      @engine = @engine_builder.rebuild_managed_container(engine)
      @build_error = @engine_builder.tail_of_build_error_log
      build_complete(@build_params)        
    else
      build_failed(params, 'No Builder')
    end
  end
  
  def restore_engine(engine)
      @build_params = {
        engine_name: engine.container_name,
        domain_name: engine.domain_name,
        host_name: engine.hostname,
        software_environment_variables: engine.environments,
        http_protocol: engine.protocol,
        memory: engine.memory,
        repository_url: engine.container_name,
        variables: engine.environments,
        reinstall: true,
        restore: true#,
        #attached_services: engine.engine_persistent_services
      }
      SystemStatus.build_starting(@build_params)
    #  SystemDebug.debug(SystemDebug.builder, 'Starting restore with params ', @build_params)
      @engine_builder = get_engine_builder(@build_params)
      if @engine_builder.is_a?(EngineBuilder)
        @engine = @engine_builder.restore_managed_container(engine)
        @build_error = @engine_builder.tail_of_build_error_log
        build_complete(@build_params)
      else
        build_failed(params, 'No Builder')
      end
    end

  private

  def get_engine_builder(params)
    @engine_builder = EngineBuilder.new(params, core)
    @engine_builder.setup_build
  end

  def get_engine_builder_bfr(repository, host, domain_name, environment)
    @build_params = {
      repository: repository,
      host_name: host,
      omain_name: domain_name,
      environment: environment
    }
    get_engine_builder(@build_params)
    #@engine_builder.setup_build
  end

  def build_failed(params, err)
    build_params[:error] = err.to_s
    @build_error = err
    core.build_stopped()
    SystemUtils.log_error_mesg(build_params.to_s, params)
    SystemStatus.build_failed(params)
    raise EnginesException.new(error_hash(params[:engine_name] + build_params.to_s + params.to_s, :build_error))
  end

  def build_complete
    bp = build_params.dup
    bp.delete(:service_builder)
    SystemStatus.build_complete(bp)
    core.build_stopped()
    true
  end

  def core
    @core ||= EnginesCore.instance
  end
end
