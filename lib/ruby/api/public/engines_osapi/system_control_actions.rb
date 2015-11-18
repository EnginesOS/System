module SystemControlActions
  def restart_mgmt 
    return success("mgmt", 'Restart Management Service') if @core_api.restart_mgmt
     return failed("mgmt", @core_api.last_error,self)
   end
   
   def restart_registry
     return success("registry", 'Restart Resgitry Service') 
   end
   
 
  def restart_system
    return success('System', 'System Restarting') if @core_api.restart_system
    failed('System', 'not permitted', 'System Restarting')
  end

end