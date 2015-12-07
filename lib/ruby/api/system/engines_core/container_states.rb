module ContainerStates
  def get_engines_states
  r=   service_manager.get_engines_states
    p :get_engines_states
            p r
            r
   end
   
   def get_services_states
   r =  service_manager.get_services_states
     p :get_services_states
        p r
        r
   end
 
end