module ManagedContainerOnAction
  def on_start(what)
    @container_mutex.synchronize {
      @stop_reason = nil    
      set_running_user
     # STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + what.to_s)
      SystemDebug.debug(SystemDebug.container_events, :ONSTART_CALLED, what)
      @out_of_memory = false
      if @consumer_less
        @has_run = true
        return save_state
      end
      # MUst register post each start as IP Changes (different post reboot)     
      register_with_dns    
      if  @has_run == false
        add_nginx_service if @deployment_type == 'web'
      end
      @has_run = true
      save_state
      begin
      @container_api.register_non_persistent_services(self)
      rescue
       return on_stop(nil) unless is_running?
      end
      save_state
    }
  end

  def on_create(event_hash)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      @container_id = event_hash[:id]
      clear_error
      @has_run = false
      @container_api.apply_schedules(self)
      save_state    
      SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
    }
    start_container
  end

  def on_stop(what, exit_code = 0)
    @exit_code = exit_code
    SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)    
    @stop_reason = what if @stop_reason.nil?
    return unless what == 'die'
    @had_out_memory = @out_of_memory
    @out_of_memory = false
    save_state
    #return true if @consumer_less    
    # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
    @container_api.deregister_non_persistent_services(self)
  end

  def out_of_mem(what)
    SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    @out_of_memory = true
    @had_out_memory = true
    save_state
  end

end