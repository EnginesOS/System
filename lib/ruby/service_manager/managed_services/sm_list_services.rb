module SMListServices
  def list_persistent_services(engine)
     get_engine_persistent_services({
       parent_engine: engine.container_name,
       container_type: engine.ctype
     })
   end
 
   def list_non_persistent_services(engine)
     get_engine_nonpersistent_services({
       parent_engine: engine.container_name,
       container_type: engine.ctype
     })
   end
end