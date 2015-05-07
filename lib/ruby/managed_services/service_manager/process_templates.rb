module ProcessTemplates
  
  require_relative "../../engine_builder/templating.rb"
  require_relative "../../engine_builder/SystemAccess.rb"
  include Templating
  
  @builder_public = nil
  @system_access = SystemAccess.new
  #@builder_public.blueprint
  @engine_public = nil
  
  
  
  def engine_environment
    return nil
  end
  
  def proccess_templated_service_hash(service_hash,container)
    
  end
  
end