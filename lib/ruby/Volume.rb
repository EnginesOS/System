require_relative 'StaticService.rb'
class Volume < StaticService #Latter will include group and perhaps other attributes
 
  def initialize(name)
   @name = name
   @serviceType="fs"
   @localpath=SysConfig.LocalFSVolHome
   @remotepath=SysConfig.CONTFSVolHome
   @mapping_permissions="rw"
   @vol_permissions=nil
  end
  
  def initialize(name,localpath,remotepath,mapping_permissions,vol_permissions)
    @serviceType="fs"
    @name = name
           if remotepath !=nil        
             @remotepath=remotepath
           else
             @remotepath=SysConfig.CONTFSVolHome
           end
           if localpath !=nil        
             @localpath=localpath
           else
             @localpath=SysConfig.LocalFSVolHome
           end
    @mapping_permissions= mapping_permissions
    @vol_permissions=vol_permissions
  end

  
  attr_reader :mapping_permissions,:name,:remotepath,:localpath,:user,:group,:vol_permissions,:mapping_permissions
 
#  def permissions
#    @mapping_permissions
#  end
#  
  def add_backup_src_to_hash backup_hash
    backup_hash[:source_type] = "fs"
    backup_hash[:source_name] = @name  
  end
  
end