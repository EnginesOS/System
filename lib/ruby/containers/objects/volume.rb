require_relative 'static_service.rb'
class Volume < StaticService #Latter will include group and perhaps other attributes
 
#  def initialize(name)
#   @name = name
#   @serviceType = 'fs'
#   @localpath = SystemConfig.LocalFSVolHome
#   @remotepath = SystemConfig.CONTFSVolHome
#   @mapping_permissions = 'rw'
#   @vol_permissions = nil
#  end
  
  
  def initialize(service_hash)
    
    @name = service_hash[:variables][:service_name]
    @vol_permissions  = PermissionRights.new(service_hash[:parent_engine] , '', '')
    @serviceType = 'fs'
    @remotepath = service_hash[:variables][:engine_path]
    @localpath = service_hash[:variables][:volume_src]
    @mapping_permissions = 'rw'
    
  end
    
  def initialize(name, localpath, remotepath, mapping_permissions, vol_permissions)
    @serviceType = 'fs'
    @name = name
           if remotepath.nil? == false       
             @remotepath = remotepath
           else
             @remotepath = SystemConfig.CONTFSVolHome
           end
           if localpath.nil? == false       
             @localpath = localpath  
             # FIXME: SHOULD NOT ACCEPT nil
           else
             @localpath =  SystemConfig.LocalFSVolHome + '/name'
           end
    @mapping_permissions = mapping_permissions
    @vol_permissions = vol_permissions
  end

  attr_reader :mapping_permissions, :name, :remotepath, :localpath, :user, :group, :vol_permissions, :mapping_permissions
 
  def Volume.complete_service_hash(service_hash)
    service_hash[:variables][:engine_path] = service_hash[:variables][:service_name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
     if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path]  == '/home/app'     
       service_hash[:variables][:engine_path] = '/home/app/'
     else
       service_hash[:variables][:engine_path] = '/home/fs/' + service_hash[:variables][:engine_path] unless service_hash[:variables][:engine_path].start_with?('/home/fs/') ||service_hash[:variables][:engine_path].start_with?('/home/app')
     end
     service_hash[:variables][:service_name] = service_hash[:variables][:engine_path].gsub(/\//,'_')
     service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine].to_s  + '/' + service_hash[:variables][:service_name].to_s unless service_hash[:variables].key?(:volume_src) && service_hash[:variables][:volume_src].to_s != ''
   
     service_hash[:variables][:volume_src].strip!
     service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:volume_src] unless service_hash[:variables][:volume_src].start_with?(SystemConfig.LocalFSVolHome)
    service_hash
  end
#  def permissions
#    @mapping_permissions
#  end
#  
  def parent_engine
    vol_permissions.owner
  end
  
  def add_backup_src_to_hash(backup_hash)
    backup_hash[:source_type] = 'fs'
    backup_hash[:source_name] = @name  
  end
 
end