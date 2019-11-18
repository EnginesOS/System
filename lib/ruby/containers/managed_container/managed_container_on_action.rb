module ManagedContainerOnAction
  def on_start(what)
    container_mutex.synchronize {
      stop_reason = nil
      exit_code = 0
      set_running_user
      #   STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + what.to_s)
      #  SystemDebug.debug(SystemDebug.container_events, :ONSTART_CALLED, what)
      # MUst register post each start as IP Changes (different post reboot)
      register_with_dns
      if consumer_less == true
        has_run = true
        STDERR.puts('CONSUMER LESS TIN')
      else
        if has_run == false
          add_wap_service if deployment_type == 'web'
        end
        has_run = true
        begin
          container_dock.register_non_persistent_services(self)
        rescue
          return on_stop(nil) unless is_running?
        end
      end
      save_state
      container_dock.register_ports(container_name, mapped_ports) if mapped_ports.is_a?(Hash)
    }
  end

  def user_clear_error
    container_mutex.synchronize {
      clear_error
    }
  end

  def on_destroy(event_hash)
    container_mutex.synchronize {
      container_dock.remove_schedules(self)
      clear_error
    }
  end

  def on_create(event_hash)
    container_mutex.synchronize {
         SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      id = event_hash[:id]
      clear_error
      has_run = false
      out_of_memory = false
      had_out_memory = false
      container_dock.apply_schedules(self)
      created = true
      save_state
       SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
    }
    start_container
  end

  def on_stop(what, exit_code = 0)
    container_mutex.synchronize {
      exit_code = exit_code
      STDERR.puts("ONStop_CALLED, #{what}")
      #  SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
      stop_reason = what if stop_reason.nil?
      if what == 'die'
        had_out_memory = out_of_memory
        out_of_memory = false
        save_state
        container_dock.deregister_non_persistent_services(self)
        container_dock.deregister_ports(container_name, mapped_ports) if mapped_ports.is_a?(Hash)
      end
    }
  end

  def out_of_mem(what)
    # SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    container_mutex.synchronize {
      out_of_memory = true
      had_out_memory = true
      save_state
    }
  end

end