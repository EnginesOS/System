class ServiceBuilder < ErrorsApi
  
  def initialize(service_manager, templater)
    @service_manager = service_manager
    @templater = templater
    @attached_services = []
  end
    
  def create_non_persistant_services(services, build_name)  
  services.each do |service_hash|
    service_def = get_service_def(service_hash)
    return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
    next if service_def[:persistant]
    service_hash = set_top_level_service_params(service_hash, build_name)
    return log_error_mesg('Failed to Attach ', service_hash) unless @service_manager.add_service(service_hash)
    @attached_services.push(service_hash)
  end
  return @attached_services
end

def create_persistant_services(services, build_name, environ)
   service_cnt = 0
 
   services.each do |service_hash|
     service_def = get_service_def(service_hash)
     return false if service_def.nil?
     if service_def[:persistant]    
       service_hash[:persistant] = true
       service_hash = set_top_level_service_params(service_hash, build_name)
       free_orphan = false
     if @service_manager.match_orphan_service(service_hash) == true
       service_hash = use_orphan(service_hash)
       @first_build = false
     elsif @service_manager.service_is_registered?(service_hash) == false
       @first_build = true
       service_hash[:fresh] = true
     else # elseif over attach to existing true attached to existing
       service_hash[:fresh] = false
       return log_error_mesg('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' Service Found', self)
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
     end
     end
     service_cnt += 1
   end
  return @attached_services
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
 
end
