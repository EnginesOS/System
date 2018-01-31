module ManagedEngineOnAction
  def on_start(event_hash)
    set_running_user
   # register_with_dns
    #  STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + event_hash.to_s)
        STDERR.puts('ONS ME TART @service_builder.run_volume_builder  is a' +  @volume_service_builder.to_s )    
    if @volume_service_builder == true
        STDERR.puts('Running @service_builder.run_volume_builder ' )
      vols = attached_services(
      {type_path: 'filesystem/local/filesystem'
      })
    if vols.is_a?(Array) && vols.length > 0 
      STDERR.puts('RuN VOLBUILER')
           @container_api.run_volume_builder(self, @cont_user_id, 'all')
      end
      @volume_service_builder = false
      @save_container = false
    end
    STDERR.puts('VOLBUILER R')   
    super
  end
end