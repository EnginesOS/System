module PublicApiEngine
 def loadManagedEngine   #vc engines system
   @system_api.loadManagedEngine(engine_name)
 end
   def get_resolved_engine_string #ex
     @core_api.get_resolved_engine_string(env_value, engine)
   end
    def get_build_report #ex
      @core_api.get_build_report(engine_name)
    end
    
    def reinstall_engine #ex
      @core_api.reinstall_engine(engine)
    end
    
 
end