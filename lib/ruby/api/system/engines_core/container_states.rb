module ContainerStates
  def get_engines_states
     @system_api.get_engines_states
   
   end
   
   def get_services_states
   r =  @system_api.get_services_states
     p :get_services_states
        p r
        r
   end
 
end