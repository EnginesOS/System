require "/opt/engines/lib/ruby/ManagedContainer.rb"

require_relative "SoftwareService.rb"
class BackupService < SoftwareService 
  
  
  def add_consumer_to_service(site_hash)
    return  create_backup(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  rm_backup(site_hash) 
    end 

  def create_backup(site_hash)
    
    begin
      
      if site_hash.has_key?(:engine_name)      
        containerName = site_hash[:engine_name]
      else
        containerName = site_hash[:parent_engine]
        
      end
      
      SystemUtils.debug_output site_hash
      #FIXME
      #kludge
      site_hash[:source_user]="testuser"
      site_hash[:source_host]="testhostl"
      site_hash[:source_pass]="testpass"
        
      if site_hash.has_key?(:source_type) == false ||  site_hash[:source_type] == "engine"
        site_hash[:source_type] ="engine"
        site_hash[:source_name] = site_hash[:parent_engine]
      elsif  site_hash[:source_type] =="fs"
        site_src=containerName + ":fs:" + site_hash[:source_name]
      else
        site_src=containerName + ":" + site_hash[:source_type] + ":" +  site_hash[:source_user] +":" +  site_hash[:source_pass] + "@" +  site_hash[:source_host] + "/" + site_hash[:source_name]
      end
      #FIXME
      site_dest=site_hash[:dest_proto] +":" + site_hash[:dest_user] + ":" + site_hash[:dest_pass] + "@" +  site_hash[:dest_address] + "/" + site_hash[:dest_folder]
      ssh_cmd=SysConfig.addBackupCmd + " " + site_hash[:name] + " " + site_src + " " + site_dest
      SystemUtils.run_system(ssh_cmd)
      #FIXME shoudl return about result and not just true
      return true
      
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end
  
  def rm_backup(site_hash)
    clear_error
    begin
      ssh_cmd=SysConfig.rmBackupCmd + " " + site_hash[:name]
      return SystemUtils.run_system(ssh_cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end
  
  def get_site_hash(site_hash)
         

    site_hash[:service_provider] = "EnginesSystem"
             site_hash[:service_type]='backup'
    return site_hash       
   end
   
 
end