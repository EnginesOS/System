class ServiceBuilder < ErrorsApi
  
  attr_reader :volumes,:app_is_persistant
  
  def initialize(service_manager, templater, engine_name, attached_services)
    @engine_name = engine_name
    @service_manager = service_manager
    @templater = templater
    @attached_services =  attached_services 
    @volumes = {}
    @orphans = []
    @app_is_persistant = false
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
     return log_error_mesg("Problem with service hash", service_hash) if service_hash.is_a?(FalseClass)
        existing = match_service_to_existing(service_hash, use_existing) 
        if existing.is_a?(Hash)
          service_hash = existing
          service_hash[:shared] = true
          @first_build = false
          free_orphan = true if @service_manager.match_orphan_service(service_hash) == true
        elsif @service_manager.match_orphan_service(service_hash) == true #auto orphan pick up
          service_hash = use_orphan(service_hash)
          @first_build = false
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
        else
          return log_error_mesg('Failed to attach ' + @service_manager.last_error, service_hash)
        end
        
 end
 
 def match_service_to_existing(service_hash, use_existing)
   return false if use_existing.nil?

   use_existing.each do |existing_service|
     p :create_type
      p existing_service[:create_type]
     next if existing_service[:create_type] == 'new'
     p existing_service[:type_path] + " and " + service_hash[:type_path]
     p existing_service[:publisher_namespace] + " and " + service_hash[:publisher_namespace]
     if existing_service[:publisher_namespace] == service_hash[:publisher_namespace]\
       && existing_service[:type_path] == service_hash[:type_path]
         p :comparing
         # FIX ME run a check here on service hash
         return use_active_service(service_hash, existing_service) if existing_service[:create_type] == 'active'
         return use_orphan(existing_service) if existing_service[:create_type] == 'orphan'        
     end
  end  
   log_error_mesg('Failed to Match Service to attach', service_hash)
 end
 
 def use_active_service(service_hash, existing_service )
  s = @service_manager.get_service_entry(existing_service)
  p :usering_active_Serviec

  s[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
  s[:fresh] = false
  s[:shared] = true
   p s 
  return s
 end
 
 def use_orphan(service_hash)
   p :attaching_orphan
    p service_hash
   service_hash = @service_manager.retrieve_orphan(service_hash)
   p :retrieved_orphan
    p service_hash
   @orphans.push(service_hash.dup) 
    service_hash[:fresh] = false   
    reparent_orphan(service_hash)
    unless service_hash.nil? 
      p :from_reparemt
      p service_hash
      service_hash[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'     
    end
      return service_hash
 end
 
 def reparent_orphan(service_hash)
   
   service_hash[:old_parent] =  service_hash[:parent_engine]
   service_hash[:parent_engine] = @engine_name
   service_hash[:fresh] = false      
   service_hash[:freed_orphan] = true    
   #resuse_service_hash = @service_manager.reparent_orphan(service_hash)
   return service_hash
 end

 def release_orphans()
   @orphans.each do |service_hash|
     @service_manager.release_orphan(service_hash)
   end
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
    service_hash[:variables][:engine_path] = service_hash[:variables][:service_name] if service_hash[:variables][:engine_path].nil? || service_hash[:variables][:engine_path] == ''
    if service_hash[:variables][:engine_path].start_with?('/home/app/') || service_hash[:variables][:engine_path]  == '/home/app' 
      @app_is_persistant = true     
    else
      service_hash[:variables][:engine_path] = '/home/fs/' + service_hash[:variables][:engine_path] unless service_hash[:variables][:engine_path].start_with?('/home/fs/') ||service_hash[:variables][:engine_path].start_with?('/home/app')  
    end
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine].to_s  + '/' + service_hash[:variables][:service_name].to_s unless service_hash[:variables].key?(:volume_src)
    
    service_hash[:variables][:volume_src].strip!
    service_hash[:variables][:volume_src] = SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:volume_src] unless service_hash[:variables][:volume_src].start_with?(SystemConfig.LocalFSVolHome)
       
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash[:variables][:service_name], service_hash[:variables][:volume_src], service_hash[:variables][:engine_path], 'rw', permissions)
    @volumes[service_hash[:variables][:service_name]] = vol
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
end
