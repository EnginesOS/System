module ProcessTemplates
  
  require_relative "../../engine_builder/templating.rb"
  include Templating
  
  @builder_public = nil
  @system_access = nil
  #@builder_public.blueprint
  @engine_public = nil
  
  
  
  def engine_environment
    return nil
  end
  
  
  
end