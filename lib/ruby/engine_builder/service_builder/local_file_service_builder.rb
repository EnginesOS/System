module LocalFileServiceBuilder
  def add_file_service(service_hash)
    @app_is_persistent = true if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path] == '/home/app'
    service_hash = Volume.complete_service_hash(service_hash)
    @default_vol = service_hash[:variables][:service_name] if @default_vol.nil?
    write_vol_map(service_hash)
    true
  end

  def write_vol_map(service_hash)
    FileUtils.mkdir(@basedir.to_s + '/home/volumes/') unless File.directory?(@basedir.to_s + '/home/volumes/')
    f = File.new(@basedir.to_s + '/home/volumes/' + service_hash[:variables][:service_name], 'w')
    begin
      f.write(service_hash[:variables][:engine_path])
    ensure
      f.close
    end
  end
end