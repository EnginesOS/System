module ManagedUtilityOnAction
  def on_create(event_hash)
 #   STDERR.puts('On Create UIL ' + @container_name.to_s)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      @container_id = event_hash[:id]
      @out_of_memory = false
      @had_out_memory = false
      save_state
    }  
    start_container
  end

  def on_start(event_hash)
    STDERR.puts('MANAGE UTIL Started')
  end

  def on_stop(what, exit_code = 0)
  #  STDERR.puts('MANAGE UTIL Stopped')
    @exit_code = exit_code
    @had_out_memory = @out_of_memory
    @out_of_memory = false
    @container_api.save_container_log(self, {max_size: 2048, over_write: true})
  ensure
    save_state
 # STDERR.puts('MANAGE UTIL Self Destruct')
    destroy_container
  end

end