module LocalFileServiceBuilder
  def run_volume_builder(container,username)
    clear_error
    if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
      command = 'docker stop volbuilder'
      SystemUtils.run_system(command)
      command = 'docker rm volbuilder'
      SystemUtils.run_system(command)
      File.delete(SystemConfig.CidDir + '/volbuilder.cid')
    end
    mapped_vols = get_volbuild_volmaps(container)
    command = 'docker run --name volbuilder --memory=128m -e fw_user=' + username.to_s + ' -e data_gid=' + container.data_gid.to_s + '   --cidfile ' +SystemConfig.CidDir + 'volbuilder.cid ' + mapped_vols.to_s + ' -t engines/volbuilder:' + SystemUtils.system_release + ' /bin/sh /home/setup_vols.sh '
    SystemDebug.debug(SystemDebug.services,'Run volume builder',command)

    #run_system(command)
   # result = SystemUtils.execute_command(command)
    volbuilder = @core_api.loadManagedUtility('volbuilder')
    util_params = {}
    util_params[:volume] = '/'
    util_params[:fw_user] = username.to_s
    util_params[:target] = container.container_name
    util_params[:data_gid] = container.data_gid.to_s
    result =  volbuilder.execute_command(:setup_engine, util_params)
    STDERR.puts(' excute utile REsult  ' + result.to_s)
    return result if result.is_a?(EnginesError)
    return true if result[:stdout] == 'OK'
    return log_error_mesg('volbuild problem ' + result.to_s, result)
#    if result[:result] != 0
#      p result[:stdout]
#      @last_error='Volbuilder: ' + command + '->' + result[:stdout].to_s + ' err:' + result[:stderr].to_s
#      p @last_error
#      return false
#    end
    #Note no -d so process will not return until setup.sh completes
#    command = 'docker rm volbuilder'
#    File.delete(SystemConfig.CidDir + '/volbuilder.cid') if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
#    res = SystemUtils.run_system(command)
#    SystemUtils.log_error(res) if res.is_a?(FalseClass)
    # don't return false as
    #return true
  rescue StandardError => e
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
    return true
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