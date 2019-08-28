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
    @build_controller.abort_build() unless @build_controller.nil?
    @build_thread.terminate unless @build_thread.nil?
    build_stopped()
    rescue
  end

  def get_build_report(engine_name)
    @system_api.get_build_report(engine_name)
  end

  def save_build_report(container, build_report)
    @system_api.save_build_report(container, build_report)
  end
  
  def trigger_install_event(engine_name, state = nil)
    @system_api.trigger_install_event(engine_name, state)
  end
  
  def build_engine(params)
    
    @build_controller = BuildController.new(self) unless @build_controller
    @build_thread.exit unless @build_thread.nil?
    @build_controller.prepare_engine_build(params)
    @build_thread = Thread.new { @build_controller.build_engine }
    @build_thread[:name]  = 'build engine'
    trigger_install_event(params[:engine_name], 'installing')
    unless @build_thread.alive?
      trigger_install_event(params[:engine_name], 'failed')
      raise EnginesException.new(error_hash(params[:engine_name], 'Build Failed to start'))
    end
    true
    rescue StandardError => e
      SystemUtils.log_exception(e , 'reinstall_engine:' + params.to_s)
    @build_thread.exit unless @build_thread.nil?
      false
  end
end