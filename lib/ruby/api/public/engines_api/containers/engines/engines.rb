module Engines
  def list_managed_engines
     @system_api.list_managed_engines
   end
  def getManagedEngines
    @system_api.getManagedEngines
  end
   
  def  build_engine(params)
    @core_api.build_engine(params)
      end
      
end