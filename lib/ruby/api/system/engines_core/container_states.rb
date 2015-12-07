module ContainerStates
  def get_engines_states
  r=   @system_api.get_engines_states
    p :get_engines_states
            p r
            r
   end
   
   def get_services_states
   r =  @system_api.get_services_states
     p :get_services_states
        p r
        r
   end
 
end