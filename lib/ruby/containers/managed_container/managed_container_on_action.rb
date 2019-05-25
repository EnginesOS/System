module ManagedContainerOnAction
  def on_start(what)
    
    @container_mutex.synchronize {
      @stop_reason = nil
      @exit_code = 0
      set_running_user
    #   STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + what.to_s)
    #  SystemDebug.debug(SystemDebug.container_events, :ONSTART_CALLED, what)
      # MUst register post each start as IP Changes (different post reboot)
      register_with_dns
      
      if @consumer_less == true
        @has_run = true
        STDERR.puts('CONSUMER LESS TIN')
      else       
        if @has_run == false
     #     STDERR.puts('FIRST TIME')
          add_wap_service if @deployment_type == 'web'
     #   else
     #     STDERR.puts('HAS TUN TIME')
        end
        @has_run = true
        begin
          @container_api.register_non_persistent_services(self)
        rescue
          return on_stop(nil) unless is_running?
        end
      end
      save_state
      @container_api.register_ports(@container_name, @mapped_ports) if @mapped_ports.is_a?(Hash)
    }
  end
  
  def user_clear_error
    @container_mutex.synchronize {
      clear_error
    }
  end

  def on_create(event_hash)
    @container_mutex.synchronize {
   #   SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED, event_hash)
      @container_id = event_hash[:id]
      clear_error
      @has_run = false
      @out_of_memory = false
      @had_out_memory = false
      @container_api.apply_schedules(self)
      @created = true
      save_state
    #  SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
    }
    @container_api.init_container_info_dir(self)
    start_container
  end

  def on_stop(what, exit_code = 0)
    @exit_code = exit_code
  #  SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
    @stop_reason = what if @stop_reason.nil?
    if what == 'die'
      @had_out_memory = @out_of_memory
      @out_of_memory = false
      save_state
      #return true if @consumer_less
      # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
      @container_api.deregister_non_persistent_services(self)
      @container_api.deregister_ports(@container_name, @mapped_ports) if @mapped_ports.is_a?(Hash)
    end
  end

  def out_of_mem(what)
   # SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    @out_of_memory = true
    @had_out_memory = true
    save_state
  end

end