module PersistantServiceBuilder
  def create_persistent_services(services, environ, use_existing)
    r = ''
    SystemDebug.debug(SystemDebug.builder,:services ,services)
    services.each do | service_hash |
      SystemDebug.debug(SystemDebug.builder,:servicer_hash,service_hash)
      service_def = software_service_definition(service_hash)
      return log_error_mesg('no matching service definition for ' + service_hash.to_s ,self) if service_def.nil?
      if service_def[:persistent] 
        service_hash[:persistent] = true        
        return r if (r = process_persistent_service(service_hash, environ, use_existing)).is_a?(EnginesError)
      end
    end
    return true
    rescue Exception => e
        SystemUtils.log_exception(e)
  end

  def process_persistent_service(service_hash, environ, use_existing)
    SystemDebug.debug(SystemDebug.builder,:service ,service_hash)
    service_hash = set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg("Problem with service hash", service_hash) if service_hash.is_a?(FalseClass)
    existing = match_service_to_existing(service_hash, use_existing)
    if existing.is_a?(Hash)
      service_hash[:fresh] = false
      @first_build = false
      SystemDebug.debug(SystemDebug.builder,:existing_service ,service_hash)
      return attach_existing_service_to_engine(service_hash, existing) if existing[:shared] == true
      service_hash = existing #Orphan case    
    elsif @core_api.match_orphan_service(service_hash) == true #auto orphan pick up
      SystemDebug.debug(SystemDebug.builder,:orphan_service ,service_hash)
      service_hash = use_orphan(service_hash)
      @first_build = false
      SystemDebug.debug(SystemDebug.builder, ' use orphan ', service_hash)
    elsif @core_api.service_is_registered?(service_hash) == false
      @first_build = true
      service_hash[:fresh] = true
    else # elseif over attach to existing true attached to existing
      service_hash[:fresh] = false
      return log_error_mesg('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' Service Found', self)
    end

    if service_hash[:type_path] == 'filesystem/local/filesystem'
      SystemDebug.debug(SystemDebug.builder,:local_file_service ,service_hash)
      result = add_file_service(service_hash)
      return log_error_mesg('failed to create fs',self) unless result
    end
    SystemDebug.debug(SystemDebug.builder,:builder_attach_service, service_hash)
    @templater.fill_in_dynamic_vars(service_hash)

    constants = SoftwareServiceDefinition.service_constants(service_hash)
    environ.concat(constants)
    environ.concat(SoftwareServiceDefinition.service_environments(service_hash))
    SystemDebug.debug(SystemDebug.builder, :with_env, environ)
    # FIXME: release orphan should happen latter unless use reoprhan on rebuild failure
    r = @core_api.create_and_register_service(service_hash)
     return r if r.is_a?(EnginesError)
      @attached_services.push(service_hash)
    return true
    rescue Exception => e
        SystemUtils.log_exception(e)
  end

  def match_service_to_existing(service_hash, use_existing)
    return false if use_existing.nil?
    return log_error_mesg(" Existing Attached services should be an array",use_existing) unless use_existing.is_a?(Array)
    use_existing.each do |existing_service|
      SystemDebug.debug(SystemDebug.builder, :create_type, existing_service)
      next if existing_service[:create_type] == 'new'
      next if existing_service[:create_type].nil?
      SystemDebug.debug(SystemDebug.builder, existing_service[:type_path] + " and " + service_hash[:type_path], existing_service[:publisher_namespace] + " and " + service_hash[:publisher_namespace])
      if existing_service[:publisher_namespace] == service_hash[:publisher_namespace]\
      && existing_service[:type_path] == service_hash[:type_path]
        SystemDebug.debug(SystemDebug.builder, :comparing_services)
        # FIX ME run a check here on service hash
        return use_active_service(service_hash, existing_service) if existing_service[:create_type] == 'existing'
        return use_orphan(existing_service) if existing_service[:create_type] == 'orphan'
      end
    end
    return false
    rescue Exception => e
        SystemUtils.log_exception(e)
  end

  def use_active_service(service_hash, existing_service )
    s = @core_api.get_service_entry(existing_service)
    s[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    s[:fresh] = false
    s[:shared] = true
    SystemDebug.debug(SystemDebug.builder, :usering_active_Serviec, s)
    return s
    rescue Exception => e
        SystemUtils.log_exception(e)
  end

  def attach_existing_service_to_engine(service_hash, existing)
    SystemDebug.debug(SystemDebug.builder, :attach_existing_service_to_engine, service_hash, existing)
#    params =  service_hash.dup
#    params[ :existing_service] = existing
#    trim_to_editable_variables(params)
#    if @core_api.attach_existing_service_to_engine(params) 
#      if service_hash[:type_path] == 'filesystem/local/filesystem'
#        result = add_file_service(service_hash)
#       log_error_mesg('failed to create fs',self) unless result
#      end
    existing[:owner] =  existing[:parent_engine]  
    service_hash[:existing_service] = existing
   
    if  @core_api.connect_share_service(service_hash)     
      result = add_file_service(service_hash)
      return log_error_mesg('failed to create fs',self) unless result
      @attached_services.push(service_hash)
      return true
    end
   # end
    return log_error_mesg('failed to attach_existing_service_to_engine(params)',params)
    rescue Exception => e
        SystemUtils.log_exception(e)
  end


end