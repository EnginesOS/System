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
    SystemDebug.debug(SystemDebug.builder, :abort_build)
    core.abort_build
  end

  def prepare_engine_build(memento, build_params)
    SystemDebug.debug(SystemDebug.builder, :builder_params, memento, build_params)
    #build_params = memento.to_h.merge(custom_params)
    engine_builder.build_params(memento, build_params) unless memento.nil?
    SystemStatus.build_starting(build_params)
  end

  def build_engine
    @engine = engine_builder.build_from_blue_print
    #SystemDebug.debug(SystemDebug.builder, :build_error, @engine_builder.build_error.to_s) unless  @engine_builder.build_error.nil?
    build_complete
  end

  def buildEngine(repository, host, domain_name, environment)
    @build_params = {
      repository: repository,
      host_name: host,
      omain_name: domain_name,
      environment: environment
    }
    SystemStatus.build_starting(@build_params)
    @engine = engine_builder.build_from_blue_print
    @engine.save_state
    build_complete
    @engine
  end

  def reinstall_engine(p)
    @build_params = p
    SystemStatus.build_starting(@build_params)
    # SystemDebug.debug(SystemDebug.builder, 'Starting resinstall with params ', @build_params)
    @engine = engine_builder.rebuild_managed_container(@build_params)
    @build_error = engine_builder.tail_of_build_error_log
    build_complete
  end

  def restore_engine(p)
    @build_params = p
    SystemStatus.build_starting(@build_params)
    #  SystemDebug.debug(SystemDebug.builder, 'Starting restore with params ', @build_params)
    @engine = engine_builder.restore_managed_container(engine)
    @build_error = engine_builder.tail_of_build_error_log
    build_complete
  end

  def engine_builder
    if @engine_builder.nil?
      @engine_builder = EngineBuilder.instance
      @engine_builder.build_params=(@build_params) unless @build_params.nil?
    end
    @engine_builder
  end

  protected

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
