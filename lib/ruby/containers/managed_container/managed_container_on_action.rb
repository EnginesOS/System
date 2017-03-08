module ManagedContainerOnAction
  def on_start(what)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events,:ONSTART_CALLED,what)
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
      @container_api.register_non_persistent_services(self)
      true
    }
  rescue StandardError => e
    log_exception(e)
  end

  def on_create(event_hash)
    @container_mutex.synchronize {
      SystemDebug.debug(SystemDebug.container_events,:ON_Create_CALLED,event_hash)
      @container_id = event_hash[:id]
      @out_of_memory = false
      @had_out_memory = false
      @has_run = false
      @container_api.apply_schedules(self)
      save_state
      return true if @consumer_less
      #return if what == 'create'
     # register_with_dns # MUst register each time as IP Changes

      # @container_api.register_non_persistent_services(self)
      SystemDebug.debug(SystemDebug.container_events,:ON_Create_Finised,event_hash)
      true
    }
  rescue StandardError => e
    log_exception(e)
  end

  def on_stop(what)

    SystemDebug.debug(SystemDebug.container_events,:ONStop_CALLED,what)
    @had_out_memory = @out_of_memory
    @out_of_memory = false
    save_state
    return true if @consumer_less
    deregister_with_dns # MUst register each time as IP Changes
    @container_api.deregister_non_persistent_services(self)
    true
  rescue StandardError => e
    log_exception(e)
  end

  def out_of_mem(what)

    SystemDebug.debug(SystemDebug.container_events,:OUTOF_MEM_CALLED,what)
    @out_of_memory = true
    @had_out_memory = true
    save_state
  rescue StandardError => e
    log_exception(e)
  end

end