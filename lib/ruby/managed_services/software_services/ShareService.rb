
require_relative "SoftwareService.rb"

class ShareService < SoftwareService 
  
  def add_consumer_to_service(site_hash)
    
      return  @core_api.add_share(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
       return  @core_api.rm_share(site_hash)  
    end 
#     
#  def get_site_hash(site_hash)
#
##        site_hash = Hash.new()
##        site_hash[:type] #db or fs
##        site_hash[:owner]=volume.vol_permissions.owner
##        site_hash[:sharee] #what engine/service
##        site_hash[:name]=volume.name 
##        site_hash[:localpath]=volume.localpath #relative dir
##        site_hash[:remotepath]=volume.remotepath #where in container mounts
##        site_hash[:mapping_permission]=volume.mapping_permissions #:ro or :rw
###        site_hash[:permissions]=volume.vol_permissions.ro_group #:ro or :rw
##    site_hash[:publisher_namespace] = "EnginesSystem"
##    site_hash[:service_type]='share'
#        return site_hash          
#   end
#   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end
