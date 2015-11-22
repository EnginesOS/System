module BuildController
  
  def build_started(controller)
    @current_builder = controller
  end
  
  def build_stoped()
      @current_builder = nil
    end
    
  def abort_build()
    @current_builder.abort_build() unless @current_builder.nil?      
  end
    
end