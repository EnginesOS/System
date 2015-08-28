#require_relative  '../ManagedService.rb'

class VolumeService < ManagedService
  def add_consumer_to_service(service_hash)
    return add_volume(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  rm_volume(service_hash)
  end

  def add_volume(service_hash)
      dest = SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine] + '/' + service_hash[:service_handle]
      FileUtils.mkdir_p(dest) unless Dir.exist?(dest)
    rescue  Exception=>e
      log_exception(e)
  end

  def rm_volume(service_hash)
      cmd = 'docker run  --name volbuilder --memory=20m -e fw_user=www-data    -v /var/lib/engines/fs/' + service_hash[:parent_engine] + ':/dest/fs:rw   -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh fs'  
      retval =  SystemUtils.run_system(cmd)
      cmd = 'docker rm volbuilder'
      retval =  SystemUtils.run_system(cmd)      
      return FileUtils.rm_rf( SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine]) if retval
        log_error_mesg('Failed to Delete FS:' + retval.to_s ,service_hash)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
  end

  def reregister_consumers
    
  end
end