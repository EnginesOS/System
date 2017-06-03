module ManagedUtilityOnAction
  def on_create(event_hash)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      @container_id = event_hash[:id]
      @out_of_memory = false
      @had_out_memory = false
      save_state
    }
    start_container
  end

  def on_stop(what, exit_code = 0)
    @exit_code = exit_code
    @had_out_memory = @out_of_memory
    @out_of_memory = false
    save_state
    destroy_container
  end

end