#require_relative  '../ManagedService.rb'

class VolumeService < ManagedService
  def add_consumer_to_service(service_hash)

    return add_volume(service_hash)
  end

  def rm_consumer_from_service (service_hash)

    return  rm_volume(service_hash)
  end

  def add_volume(service_hash)
    p :adding_Volume
    p service_hash

    begin

      dest = SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine] + '/' + service_hash[:service_handle]
      if Dir.exists?( dest) == false
        p dest
        FileUtils.mkdir_p(dest)
      end
      #currently the build scripts do this
      #save details with some manager
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def rm_volume(service_hash)

    begin
      cmd = 'docker run  --name volbuilder --memory=20m -e fw_user=www-data    -v /var/lib/engines/fs/' + service_hash[:parent_engine] + ':/dest/fs:rw   -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh fs'  
      retval =  SystemUtils.run_system(cmd)
      cmd = 'docker rm volbuilder'
      retval =  SystemUtils.run_system(cmd)
      
      if retval == true
        FileUtils.rm_rf( SystemConfig.LocalFSVolHome() + '/' + service_hash[:parent_engine])
          return true 
      else
        SystemUtils.log_error_mesg('Failed to Delete FS:' + retval.to_s ,service_hash)
        @last_error='Failed to Delete FS:' + retval.to_s
        return false        
      end
    
      #update details with some manager
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  #  def get_service_hash(service_hash)
  ##
  ##        service_hash = Hash.new()
  ##        service_hash[:parent_engine] = volume.parent_engine
  ##        service_hash[:publisher_namespace] = 'EnginesSystem'
  ##        service_hash[:name]=volume.name
  ##        service_hash[:localpath]=volume.localpath
  ##        service_hash[:remotepath]=volume.remotepath
  ##        service_hash[:mapping_permission]=volume.mapping_permissions
  ##        service_hash[:permissions_owner]=volume.vol_permissions.owner
  ##        service_hash[:permission_ro_grp]=volume.vol_permissions.ro_group
  ##        service_hash[:permission_rw_grp]=volume.vol_permissions.rw_group
  ##        service_hash[:service_type]='volume'
  ##    service_hash[:type_path] =  service_hash[:service_type]
  #    if service_hash.has_key?(:service_label) == false
  #      service_hash[:service_label] = service_hash[:variables][:name]
  #
  #    end
  #        return service_hash
  #   end
  #
  #noop overloads

  def reregister_consumers
    #No Need they are static
  end
end