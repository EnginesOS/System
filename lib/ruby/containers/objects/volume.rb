require_relative 'static_service.rb'
class Volume < StaticService #Latter will include group and perhaps other attributes
 
  def initialize(name)
   @name = name
   @serviceType='fs'
   @localpath=SystemConfig.LocalFSVolHome
   @remotepath=SystemConfig.CONTFSVolHome
   @mapping_permissions='rw'
   @vol_permissions=nil
  end
  
  def initialize(name,localpath,remotepath,mapping_permissions,vol_permissions)
    @serviceType='fs'
    @name = name
           if remotepath !=nil        
             @remotepath=remotepath
           else
             @remotepath=SystemConfig.CONTFSVolHome
           end
           if localpath !=nil        
             @localpath=localpath  
             #FIXME SHOULD NOT ACCEPT nil
           else
             @localpath=SystemConfig.LocalFSVolHome + '/name'
           end
    @mapping_permissions= mapping_permissions
    @vol_permissions=vol_permissions
  end

  attr_reader :mapping_permissions,:name,:remotepath,:localpath,:user,:group,:vol_permissions,:mapping_permissions
 
#  def permissions
#    @mapping_permissions
#  end
#  
  def parent_engine
    vol_permissions.owner
  end
  
  def add_backup_src_to_hash backup_hash
    backup_hash[:source_type] = 'fs'
    backup_hash[:source_name] = @name  
  end
  
end