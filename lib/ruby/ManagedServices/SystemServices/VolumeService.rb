require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "../ManagedService.rb"
class VolumeService < ManagedService 
  
  def add_consumer_to_service(site_hash)
  
      return  add_volume(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
    
       return  rm_volume(site_hash)  
    end 
     
    
  def add_volume(site_hash)
    p :adding_Volume
    p site_hash
    begin
      dest = SysConfig.LocalFSVolHome() + "/" + site_hash[:parent_engine] + "/" + site_hash[:variables][:engine_path]
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

  def rm_volume(site_hash)
    
    begin
      puts "would remove " + site_hash[:dest]
      #update details with some manager
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def get_site_hash(site_hash)
#       
#        site_hash = Hash.new()
#        site_hash[:parent_engine] = volume.parent_engine
#        site_hash[:publisher_namespace] = "EnginesSystem"
#        site_hash[:name]=volume.name 
#        site_hash[:localpath]=volume.localpath
#        site_hash[:remotepath]=volume.remotepath 
#        site_hash[:mapping_permission]=volume.mapping_permissions
#        site_hash[:permissions_owner]=volume.vol_permissions.owner
#        site_hash[:permission_ro_grp]=volume.vol_permissions.ro_group
#        site_hash[:permission_rw_grp]=volume.vol_permissions.rw_group
#        site_hash[:service_type]='volume' 
        return site_hash          
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end