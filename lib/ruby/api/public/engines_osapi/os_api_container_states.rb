module OsApiContainerStates
  
  def get_engines_states
    r =  @core_api.get_engines_states
    p :get_engines_states
    p r
    r
   end
   
   def get_services_states
     r = @core_api.get_services_states
     p :get_engines_states
     p r
     r
   end
end
