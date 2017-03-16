#require_relative  '../ManagedService.rb'

class VolumeService < ManagedService
  def add_consumer_to_service(service_hash)
    return add_volume(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return rm_volume(service_hash)
  end

  def add_volume(volbuilder, service_hash)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')

    
       util_params = {}
       util_params[:volume] =  service_hash[:variables][:service_name]
       util_params[:fw_user] = service_hash[:variables][:user]
       util_params[:target] =  service_hash[:parent_engine]
       util_params[:data_gid] = service_hash[:variables][:group]
       result =  volbuilder.execute_command(:add_volume, util_params)
  rescue  Exception=>e
    log_exception(e)
  end

  def rm_volume(volbuilder, service_hash)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    volbuilder.drop_log_dir
    volbuilder.drop_state_dir
    
    util_params = {}
    util_params[:volume] =  service_hash[:variables][:service_name]
    util_params[:fw_user] = service_hash[:variables][:user]
    util_params[:target] =  service_hash[:parent_engine]
    util_params[:data_gid] = service_hash[:variables][:group]
    result =  volbuilder.execute_command(:remove_volume, util_params)
#    return log_error_mesg('invalid parent dir in rm_volume',service_hash) unless service_hash[:variables][:volume_src] .start_with?( SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine])
#    cmd = 'docker_run  --name volbuilder --memory=20m -e fw_user=www-data    -v ' + service_hash[:variables][:volume_src] + ':/dest/fs:rw   -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh fs'
#    retval =  SystemUtils.run_system(cmd)
#    cmd = 'docker_rm volbuilder'
#    retval =  SystemUtils.run_system(cmd)
    return FileUtils.rm_rf( service_hash[:variables][:volume_src] ) #SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine] +  '/' + service_hash[:service_handle]) if retval
  
    
  rescue  Exception=>e
    raise EnginesException.new(error_hash('Failed to Delete FS:' + service_hash.to_s, service_hash))
  end

  def reregister_consumers

  end

  private

  def make_fs_root_dir(dest)

    FileUtils.mkdir_p(dest)
    FileUtils.chmod('ug=wrx,o=rx',dest)
    FileUtils.chown(nil,22020,dest)

  end
end