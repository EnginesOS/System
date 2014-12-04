require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class VolumeService < ManagedService 
  
  def add_consumer_to_service(site_hash)
    
      return  @core_api.add_volume(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
       return  @core_api.rm_volume(site_hash)  
    end 
     
  def get_site_hash(volume)

        site_hash = Hash.new()
        site_hash[:name]=volume.name 
        site_hash[:localpath]=volume.localpath
        site_hash[:remotepath]=volume.remotepath 
        site_hash[:mapping_permission]=volume.mapping_permissions
        site_hash[:permissions_owner]=volume.vol_permissions.owner
        site_hash[:permission_ro_grp]=volume.vol_permissions.ro_group
        site_hash[:permission_rw_grp]=volume.vol_permissions.rw_group
        return site_hash          
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end