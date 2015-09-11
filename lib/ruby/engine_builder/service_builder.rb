class ServiceBuilder < ErrorsApi
  
  attr_reader :volumes
  
  def initialize(service_manager, templater, engine_name, attached_services)
    @engine_name = engine_name
    @service_manager = service_manager
    @templater = templater
    @attached_services =  attached_services 
    @volumes = {}
      p @engine_name 
  end
    
  def create_non_persistant_services(services)  
  services.each do |service_hash|
    service_def = get_service_def(service_hash)
    return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
    next if service_def[:persistant]
    service_hash = set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg('Failed to Attach ', service_hash) unless @service_manager.add_service(service_hash)
    @attached_services.push(service_hash)
  end
  return true
end

def create_persistant_services(services, environ, use_existing)
   service_cnt = 0
 
   services.each do |service_hash|
     service_def = get_service_def(service_hash)
     return log_error_mesg('no matching service definition',self) if service_def.nil?
     if service_def[:persistant]    
       service_hash[:persistant] = true
         process_persistant_service(service_hash, environ, use_existing)       
     end
     service_cnt += 1
   end
  return true
 end

 def process_persistant_service(service_hash, environ, use_existing)
   free_orphan = false   
   service_hash = set_top_level_service_params(service_hash, @engine_name)
        existing = match_service_to_existing(service_hash, use_existing) 
        if existing != false
          service_hash = existing
          @first_build = false
          free_orphan = true if @service_manager.match_orphan_service(service_hash) == true
        elsif @service_manager.match_orphan_service(service_hash) == true #auto orphan pick up
          service_hash = use_orphan(service_hash)
          @first_build = false
          free_orphan = true
        elsif @service_manager.service_is_registered?(service_hash) == false
          @first_build = true

          service_hash[:fresh] = true
        else # elseif over attach to existing true attached to existing
          service_hash[:fresh] = false
          return log_error_mesg('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' Service Found', self)
        end
       
   if service_hash[:type_path] == 'filesystem/local/filesystem'
       result = add_file_service(service_hash)
         return log_error_mesg('failed to create fs',self) unless result                
   end 
        p :attach_service
        p service_hash
        @templater.fill_in_dynamic_vars(service_hash)
         environ.concat(SoftwareServiceDefinition.service_environments(service_hash))
        p :with_env
        p service_hash
        # FIXME: release orphan should happen latter unless use reoprhan on rebuild failure
        if @service_manager.add_service(service_hash)
          @attached_services.push(service_hash)    
          release_orphan(service_hash) if free_orphan
        else
          return log_error_mesg('Failed to attach ' + @service_manager.last_error, service_hash)
        end
 end
 
 def match_service_to_existing(service_hash, use_existing)
   return false if use_existing.nil?
   use_existing.each do |existing_service|
     return false if existing_service[:create_type] == 'new'
     if existing_service[:publisher_namespace] == service_hash[:publisher_namespace]\
       && existing_service[:type_path] == service_hash[:type_path]
         return use_active_service(service_hash, existing_service) if existing_service[:create_type] = 'active'
         return use_orphan(existing_service)         
     end
  end
  return false
 end
 
 def use_active_service(service_hash, existing_service )
  s = @service_manager.get_service_entry(existing_service)
  s[:shared]=true
  return s
 end
 
 def use_orphan(service_hash)
   p :attaching_orphan
    service_hash[:fresh] = false
    new_service_hash = reattach_service(service_hash)
    if new_service_hash.nil? == false
      service_hash = new_service_hash
      service_hash[:fresh] = false      
      service_hash[:freed_orphan] = true    
    end
      return service_hash
 end
 
 def reattach_service(service_hash)
   resuse_service_hash = @service_manager.reparent_orphan(service_hash)
   return resuse_service_hash
 end

 def release_orphan(service_hash)
   @service_manager.remove_orphaned_service(service_hash)
 end
 
  def get_service_def(service_hash)
    p service_hash[:type_path]
    p service_hash[:publisher_namespace]
    return SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
  end

  def set_top_level_service_params(service_hash, container_name)
    return ServiceManager.set_top_level_service_params(service_hash, container_name)
  end

  def add_file_service(service_hash) 
    p 'Add File Service ' + service_hash[:variables][:name].to_s
    #log_build_output('Add File Service ' + name)
    dest = service_hash[:variables][:name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
    if dest.start_with?('/home/app/')
      @builder.app_is_persistant = true     
    else
      dest = '/home/fs/' + dest unless dest.start_with?('/home/fs/')
    end
    permissions = PermissionRights.new(@engine_name , '', '')
    vol = Volume.new(service_hash[:variables][:name], SystemConfig.LocalFSVolHome + '/' + @engine_name  + '/' + service_hash[:variables][:name], service_hash[:variables][:engine_path], 'rw', permissions)
    @volumes[service_hash[:variables][:name]] = vol
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
end
