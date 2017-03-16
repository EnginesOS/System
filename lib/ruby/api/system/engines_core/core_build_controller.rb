module CoreBuildController
  require_relative '../build_controller.rb'
  def build_started(controller)
    @current_builder = controller
  end

  def build_stoped()
    #STDERR.puts('BUILD STOPPED')
    @build_thread.join unless @build_thread.nil?
    @build_thread.terminate unless @build_thread.nil?
    @build_thread = nil
    @current_builder = nil
  end

  def abort_build()
    SystemDebug.debug(SystemDebug.builder, @build_controller)
    @build_controller.abort_build() unless @build_controller.nil?
    @build_thread.terminate unless @build_thread.nil?
    build_stoped()
    # @current_builder.abort_build() unless @current_builder.nil?
  end

end