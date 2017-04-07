module ManagedContainerOnAction
  def on_start(what)
    @container_mutex.synchronize {
      set_running_user
      SystemDebug.debug(SystemDebug.container_events,:ONSTART_CALLED,what)
      @out_of_memory = false
      if @consumer_less
        @has_run = true
        return save_state
      end
      save_state
    }
  end

  def on_create(event_hash)
    #    STDERR.puts('CREATE EVent on ' + container_name)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events,:ON_Create_CALLED,event_hash)
      @container_id = event_hash[:id]
      @out_of_memory = false
      @had_out_memory = false
      @has_run = false
      save_state    
      SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
    }
    start_container
  end

  def on_stop(what)
    SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
    @had_out_memory = @out_of_memory
    @out_of_memory = false
    save_state
    #return true if @consumer_less    
    # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
  end

  def out_of_mem(what)
    SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    @out_of_memory = true
    @had_out_memory = true
    save_state
  end

end