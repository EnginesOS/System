module LocalFileServiceBuilder
  def run_volume_builder(container, username)
    clear_error
    STDERR.puts('VOL BUILD PARAMS ' + container.container_name)
    volbuilder = @core_api.loadManagedUtility('fsconfigurator')
    util_params = {
      volume: '/',
      fw_user: username.to_s,
      target: container.container_name,
      target_container: container.container_name,
      data_gid: container.data_gid.to_s
    }
    STDERR.puts('VOL BUILD PARAMS ' + util_params.to_s)
    STDERR.puts('fsconfigurator ' + volbuilder.read_state)
    result = volbuilder.execute_command(:setup_engine, util_params)
    STDERR.puts('fsconfigurator ' + volbuilder.read_state)
    
    return true if result[:result] == 0
    return log_error_mesg('volbuild problem ' + result.to_s, result)

  rescue StandardError => e
    log_error_mesg('volbuild problem ' + e.to_s)
    log_exception(e)
  end

  def add_file_service(service_hash)
    SystemDebug.debug(SystemDebug.builder, 'Add File Service ' + service_hash[:variables][:name].to_s + ' ' + service_hash.to_s)
    #  Default to engine
    @app_is_persistent = true if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path]  == '/home/app'
    service_hash = Volume.complete_service_hash(service_hash)
    SystemDebug.debug(SystemDebug.builder,:complete_VOLUME_service_hash, service_hash)
    if service_hash[:share] == true
      @volumes[service_hash[:service_owner] + '_' + service_hash[:variables][:service_name]] = vol
    else
      @volumes[service_hash[:variables][:service_name]] = Volume.volume_hash(service_hash)
    end
    true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  protected

  def get_volbuild_volmaps(container)
    clear_error
    state_dir = SystemConfig.RunDir + '/containers/' + container.container_name + '/run/'
    log_dir = SystemConfig.SystemLogRoot + '/containers/' + container.container_name
    volume_option = ' -v ' + state_dir + ':/client/state:rw '
    volume_option += ' -v ' + log_dir + ':/client/log:rw '
    unless container.volumes.nil?
      container.volumes.each_value do |vol|
        SystemDebug.debug(SystemDebug.services,'build vol maps ' +  vol[:volume_name].to_s , vol)
        volume_option += ' -v ' + vol[:localpath].to_s + ':/dest/fs/' + vol[:volume_name] + ':rw'
      end
    end
    volume_option += ' --volumes-from ' + container.container_name
    return volume_option
  rescue StandardError => e
    log_exception(e)
  end
end