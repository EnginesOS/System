require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class VolumeService < ManagedService 
  
  def add_consumer_to_service(site_string)
   
      return  @docker_api.add_volume_site(site_string) 
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.rm_volume_site(site_string)  
    end 
     
  def get_site_string(volume)
    return volume.localpath + ":" + volume.remotepath + ":" + volume.mapping_permissions.owner + ":" + volume.mapping_permissions.ro_group+ ":" + volume.mapping_permissions.rw_group
   
   end
    
end