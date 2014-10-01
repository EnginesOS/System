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
#  def initialize(name,localpath,remotepath,mapping_permissions)
 #     @name = name
  #           if remotepath !=nil        
   #            @remotepath=remotepath
    #         else
     #          @remotepath=SysConfig.CONTFSVolHome
      #       end
       #      if localpath !=nil        
        #       @localpath=localpath
         #    else
          #     @localpath=SysConfig.LocalFSVolHome
           #  end
     # @mapping_permissions= mapping_permissions
     # @vol_permissions="rw"  # from others perspective ?
    #end

    
  def mapping_permissions
    @mapping_permissions
  end
  
  def name
    return @name
  end
  def remotepath
    return @remotepath
  end
  def localpath
    return @localpath
  end
  def user
    return @user    
  end
  
  def group
    return @group
  end
  
  def vol_permissions
    return @vol_permissions
  end
  def permissions
    @mapping_permissions
  end
  
  def add_backup_src_to_hash backup_hash
    backup_hash[:source_type] = fs
    backup_hash[:source_name] = name  
  end
  
end