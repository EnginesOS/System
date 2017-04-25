module ManagedUtilityOnAction
  
  def on_create(event_hash)
    #     STDERR.puts('MANAGE UTIL create event')
      @container_mutex.synchronize {
        SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
        @container_id = event_hash[:id]
        #      STDERR.puts('ID SET YTO' + @container_id.to_s )
        @out_of_memory = false
        @had_out_memory = false
        save_state
      }
    #    STDERR.puts('MANAGE UTIL create event')
      start_container
    end
    
    def on_stop
      @had_out_memory = @out_of_memory
      @out_of_memory = false
      save_state
      destroy_container
    end
    
end