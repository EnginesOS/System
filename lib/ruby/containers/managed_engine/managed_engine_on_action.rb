module ManagedEngineOnAction
  def on_start(event_hash)
    # set_running_user
   # register_with_dns
    #  STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + event_hash.to_s)
  #      STDERR.puts('ONS ME TART @service_builder.run_volume_builder  is a' +  @volume_service_builder.to_s )    
    if @volume_service_builder == true
    STDERR.puts('RuN VOLBUILER ' + @cont_user_id.to_s + ':' + container_name)        
    container_api.run_volume_builder(self, @cont_user_id, 'all')
    #  end
      @volume_service_builder = false
      @save_container = false
    end
  #  STDERR.puts('Post VOLBUILER R')   
    super
  end
end