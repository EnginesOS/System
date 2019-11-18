module SystemSystemOnAction
  def on_start(what)
    container_mutex.synchronize {
      stop_reason = nil
      set_running_user
      #     SystemDebug.debug(SystemDebug.container_events,:ONSTART_CALLED, what)
      out_of_memory = false
      has_run = true if consumer_less
      save_state
    }
  end

  def on_create(event_hash)
    #    STDERR.puts('CREATE EVent on ' + container_name)
    container_mutex.synchronize {
      #     SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      id = event_hash[:id]
      out_of_memory = false
      had_out_memory = false
      has_run = false
      save_state
      #   SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
    }
    start_container
  end

  def on_stop(what, exit_code = 0)
    exit_code = exit_code
    #    SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
    stop_reason = what if stop_reason.nil?
    if what == 'die'
      had_out_memory = out_of_memory
      out_of_memory = false
      save_state
    end
  end

  def out_of_mem(what)
    #    SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    container_mutex.synchronize {
      out_of_memory = true
      had_out_memory = true
      save_state
    }
  end

end