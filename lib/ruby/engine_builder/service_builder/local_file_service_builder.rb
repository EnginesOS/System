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
    mapped_vols = get_volbuild_volmaps container
    command = 'docker run --name volbuilder --memory=32m -e fw_user=' + username + ' -e data_gid=' + container.data_gid + '   --cidfile ' +SystemConfig.CidDir + 'volbuilder.cid ' + mapped_vols + ' -t engines/volbuilder:' + SystemUtils.system_release + ' /bin/sh /home/setup_vols.sh '
    SystemUtils.debug_output('Run volume builder',command)
    p command
    #run_system(command)
    result = SystemUtils.execute_command(command)
    if result[:result] != 0
      p result[:stdout]
      @last_error='Volbuilder: ' + command + '->' + result[:stdout].to_s + ' err:' + result[:stderr].to_s
      p @last_error
      return false
    end
    #Note no -d so process will not return until setup.sh completes
    command = 'docker rm volbuilder'
    File.delete(SystemConfig.CidDir + '/volbuilder.cid') if File.exist?(SystemConfig.CidDir + '/volbuilder.cid')
    res = SystemUtils.run_system(command)
    SystemUtils.log_error(res) if res.is_a?(FalseClass)
    # don't return false as
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def add_file_service(service_hash)
    p 'Add File Service ' + service_hash[:variables][:name].to_s
    #  Default to engine
    service_hash[:variables][:engine_path] = service_hash[:variables][:service_name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
    if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path]  == '/home/app'
      @app_is_persistant = true
      service_hash[:variables][:engine_path] = '/home/app/'
    else
      service_hash[:variables][:engine_path] = '/home/fs/' + service_hash[:variables][:engine_path] unless service_hash[:variables][:engine_path].start_with?('/home/fs/') ||service_hash[:variables][:engine_path].start_with?('/home/app')
    end
    service_hash[:variables][:service_name] = service_hash[:variables][:engine_path].gsub(/\//,'_')
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine].to_s  + '/' + service_hash[:variables][:service_name].to_s unless service_hash[:variables].key?(:volume_src)

    service_hash[:variables][:volume_src].strip!
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:volume_src] unless service_hash[:variables][:volume_src].start_with?(SystemConfig.LocalFSVolHome)

    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash[:variables][:service_name], service_hash[:variables][:volume_src], service_hash[:variables][:engine_path], 'rw', permissions)
    @volumes[service_hash[:variables][:service_name]] = vol
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
        SystemUtils.debug_output('build vol maps ' +  vol.name.to_s , vol)
        volume_option += ' -v ' + vol.localpath.to_s + ':/dest/fs/' + vol.name + ':rw'
      end
    end
    volume_option += ' --volumes-from ' + container.container_name
    return volume_option
  rescue StandardError => e
    log_exception(e)
  end
end