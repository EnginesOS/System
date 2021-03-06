require_relative 'static_service.rb'

class Volume < StaticService #Latter will include group and perhaps other attributes
  def self.volume_hash(service_hash)
    Volume.complete_service_hash(service_hash)
    r = {
      volume_name: service_hash[:variables][:service_name],
      permissions: service_hash[:variables][:permissions],
      remotepath: service_hash[:variables][:engine_path],
      localpath: service_hash[:variables][:volume_src]
    }
    r[:permissions] = 'rw' if service_hash[:variables][:permissions].nil?
    r
  end

  attr_reader :permissions, :name, :remotepath, :localpath, :user, :group, :vol_permissions, :volume_name

  def Volume.complete_service_hash(service_hash)
    service_hash[:service_handle] =  service_hash[:service_name] unless service_hash.key?(:service_handle) &&  !service_hash[:service_handle].nil?

    service_hash[:variables][:engine_path] = service_hash[:variables][:service_name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
    if service_hash[:variables][:engine_path] == '/home/app/' || service_hash[:variables][:engine_path]  == '/home/app'
      service_hash[:variables][:engine_path] = '/home/app/'
    else
      service_hash[:variables][:engine_path] = "/home/fs/#{service_hash[:variables][:engine_path]}" unless service_hash[:variables][:engine_path].start_with?('/home/fs/') ||service_hash[:variables][:engine_path].start_with?('/home/app')
    end
    unless service_hash[:variables].key?(:volume_src)
      service_hash[:variables][:volume_src] = '/' # self.default_volume_name(service_hash)
    end
    service_hash[:variables][:volume_src].strip! unless service_hash[:variables][:volume_src].nil?

    if service_hash[:variables][:volume_src].to_s == ''
      service_hash[:variables][:volume_src]  = '/' # self.default_volume_name(service_hash)
    end

    if service_hash[:shared] == true
      service_hash[:variables][:volume_src] = "#{SystemConfig.LocalFSVolHome}/#{service_hash[:parent_engine]}/#{service_hash[:variables][:volume_src]}" unless service_hash[:variables][:volume_src].start_with?(SystemConfig.LocalFSVolHome)
    end
    unless service_hash[:variables].key?(:permissions)
      service_hash[:variables][:permissions] = PermissionRights.new(service_hash[:parent_engine] , '', '')
    end
    #   SystemDebug.debug(SystemDebug.builder, :Complete_Volume_service_hash, service_hash)
    service_hash
  rescue Exception => e
    STDERR.puts('Problem with ' +service_hash.to_s)
    raise e

  end

  def self.default_volume_name(service_hash)
    service_hash[:variables][:service_name].to_s
  end

end