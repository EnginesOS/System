module CoreBuildController
  require_relative '../build_controller.rb'
  def build_started(controller)
    @current_builder = controller
  end
  
  def build_stoped()
    
    @build_thread.terminate unless @build_thread.nil?
    @build_thread = nil
    @current_builder = nil
    end
    
  def abort_build()
    
    System.execute_cmd('/opt/engines/scripts/kill_docker_builder.sh')
    
    SystemDebug.debug(SystemDebug.builder, @current_builder)
    @current_builder.abort_build() unless @current_builder.nil?      
  end
    
end