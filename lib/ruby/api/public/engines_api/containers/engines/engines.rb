module PublicApiEngines
  def list_managed_engines
     @system_api.list_managed_engines
   end
  def getManagedEngines
    @system_api.getManagedEngines
  end
  
  def get_engines_states
    @system_api.get_engines_states
  end
   
  def  build_engine(params)
    @core_api.build_engine(params)
      end
      
#  def remove_engine(engine_name, reinstall = false) was used but it wrong on this level
#    @core_api.remove_engine(engine_name, reinstall)
#  end
  
  def delete_engine(params)
    params[:remove_all_data] = true
      p :DELETE_ENGINE
      P params
    @core_api.delete_engine(params)
  end
  
end