require "/opt/engos/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class VolumeService < ManagedService 
  
  def add_consumer_to_service(site_string)
        puts "dd vol consumer " + site_string
      return  @docker_api.add_volume(site_string) 
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.rm_volume(site_string)  
    end 
     
  def get_site_string(volume)

        site_hash = Hash.new()
        site_hash[:volume_name]=volume.name 
        site_hash[:localpath]=volume.localpath
        site_hash[:remotepath]=volume.remotepath 
        site_hash[:mapping_permission]=volume.mapping_permissions
        site_hash[:permissions_owner]=volume.vol_permissions.owner
        site_hash[:permission_ro_grp]=volume.vol_permissions.ro_group
        site_hash[:permission_rw_grp]=volume.vol_permissions.rw_group
        return site_hash
          
   end
   
    
end