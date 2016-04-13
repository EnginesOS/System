module ManagedContainerOnAction
  def on_create(event_hash)
      SystemDebug.debug(SystemDebug.container_events,:ON_Create_CALLED,event_hash)    
        @container_id = event_hash['Id']
      @out_of_memory = false
      @had_out_memory =false
          save_state
       #return if what == 'create'
        register_with_dns # MUst register each time as IP Changes    
        @container_api.register_non_persistent_services(self)
      end
      
    def on_stop(what)
      SystemDebug.debug(SystemDebug.container_events,:ONStop_CALLED,what)
      @had_out_memory = @out_of_memory
      @out_of_memory = false
      save_state
   #  deregister_with_dns # MUst register each time as IP Changes    
      @container_api.deregister_non_persistent_services(self)
    end
    
    def out_of_mem(what)
      p :out_of_mem
      p what
      @out_of_memory = true
      @had_out_memory = true    
      save_state
    end
    
end