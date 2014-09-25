require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class VolumeService < ManagedService 
  
  def add_consumer_to_service(site_string)
        puts "dd vol consumer " + site_string
      return  @docker_api.add_volume(site_string) 
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.rm_volume(site_string)  
    end 
     
  def get_site_string(volume)
    return volume.name + ":" + volume.localpath + ":" + volume.remotepath + ":" + volume.mapping_permissions + ":" + volume.vol_permissions.owner + ":" + volume.vol_permissions.ro_group + ":" + volume.vol_permissions.rw_group
   
   end
    
end