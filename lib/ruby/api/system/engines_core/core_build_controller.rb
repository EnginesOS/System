module CoreBuildController
  require_relative '../build_controller.rb'
  def build_started(controller)
    @current_builder = controller
  end

  def build_stopped()
    @build_thread.join unless @build_thread.nil?
    @build_thread.terminate unless @build_thread.nil?
    @build_thread.exit unless @build_thread.nil?
    @build_thread = nil
    @current_builder = nil
    # STDERR.puts('BUIL STOPPED')
  rescue
  end

  def abort_build()
    #  SystemDebug.debug(SystemDebug.builder, @build_controller)
    build_controller.abort_build() unless build_controller.nil?
    @build_thread.terminate unless @build_thread.nil?
    build_stopped()
  rescue
  end

  def build_engine(params)
    params[:ctype] = 'app'
    params[:container_name] = params[:engine_name]
    params[:hostname] = params[:host_name]
    params[:environments] = params[:variables]
    params[:repository] = params[:repository_url]
    memento = Container::Memento.from_hash(params)    
    @build_thread.exit unless @build_thread.nil?
    build_controller.prepare_engine_build(memento, params)
    @build_thread = Thread.new { build_controller.build_engine }
    @build_thread[:name]  = 'build engine'
    event_handler.trigger_install_event(memento.container_name, 'installing')
    unless @build_thread.alive?
      event_handler.trigger_install_event(memento.container_name, 'failed')
      raise EnginesException.new(error_hash(memento.container_name, 'Build Failed to start'))
    end
    true
  rescue StandardError => e
    SystemUtils.log_exception(e , "Reinstall_engine: #{memento} with #{params}" )
    @build_thread.exit unless @build_thread.nil?
    raise e
  end

  protected

  def build_controller
    @build_controller ||= BuildController.instance
  end
end
