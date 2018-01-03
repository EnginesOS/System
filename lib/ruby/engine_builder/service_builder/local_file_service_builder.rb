module LocalFileServiceBuilder
  def add_file_service(service_hash)
    SystemDebug.debug(SystemDebug.builder, 'Add File Service ' + service_hash[:variables][:name].to_s + ' ' + service_hash.to_s)
    #  Default to engine
    @app_is_persistent = true if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path] == '/home/app'
    service_hash = Volume.complete_service_hash(service_hash)
    SystemDebug.debug(SystemDebug.builder,:complete_VOLUME_service_hash, service_hash)
    write_vol_map(service_hash)
#    if service_hash[:share] == true
#      @volumes[service_hash[:service_owner] + '_' + service_hash[:variables][:volume_name]] = Volume.volume_hash(service_hash)
#    else
#     # STDERR.puts('KEY ' + service_hash[:variables][:service_name].to_s)
#    #  STDERR.puts('FROM ' + service_hash[:variables].to_s)
#      @volumes[service_hash[:variables][:service_name]] = Volume.volume_hash(service_hash)
#    end
    true
  end

  def write_vol_map(service_hash)
   f = File.new( basedir + '/home/' + service_hash[:variables][:volume_name], 'w')
   f.write(service_hash[:variables][:volume_name])  
   f.close   
  end
end