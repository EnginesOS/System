module ProcessTemplates
  
  require_relative "../../templater/templating.rb"
  require_relative "../../system/SystemAccess.rb"
  include Templating
  
  @builder_public = nil
  @system_access = SystemAccess.new
  #@builder_public.blueprint
  
  
  
  
  def engine_environment
    return nil
  end
  
  def proccess_templated_service_hash(service_hash,container)
    
    set_system_access( @system_access )
    ret_val = Array.new
      p :processing_service_hash_ 
      p service_hash
      p :container
      p container.container_name
      fill_in_dynamic_vars(service_hash)
      
      return ret_val
  end
  
end