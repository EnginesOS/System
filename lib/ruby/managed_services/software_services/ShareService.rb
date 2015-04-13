require_relative "SoftwareService.rb"

class ShareService < SoftwareService
  def add_consumer_to_service(service_hash)

    return  @core_api.add_share(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  @core_api.rm_share(service_hash)
  end
  #
  #  def get_service_hash(service_hash)
  #
  ##        service_hash = Hash.new()
  ##        service_hash[:type] #db or fs
  ##        service_hash[:owner]=volume.vol_permissions.owner
  ##        service_hash[:sharee] #what engine/service
  ##        service_hash[:name]=volume.name
  ##        service_hash[:localpath]=volume.localpath #relative dir
  ##        service_hash[:remotepath]=volume.remotepath #where in container mounts
  ##        service_hash[:mapping_permission]=volume.mapping_permissions #:ro or :rw
  ###        service_hash[:permissions]=volume.vol_permissions.ro_group #:ro or :rw
  ##    service_hash[:publisher_namespace] = "EnginesSystem"
  ##    service_hash[:service_type]='share'
  #        return service_hash
  #   end
  #
  #noop overloads

  def reregister_consumers
    #No Need they are static
  end
end
