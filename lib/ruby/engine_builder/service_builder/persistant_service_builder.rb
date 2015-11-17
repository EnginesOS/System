module PersistantServiceBuilder
  def create_persistant_services(services, environ, use_existing)
    services.each do |service_hash|
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
      return log_error_mesg('no matching service definition',self) if service_def.nil?
      if service_def[:persistant]
        service_hash[:persistant] = true
        return false unless process_persistant_service(service_hash, environ, use_existing)
      end
    end
    return true
  end

  def process_persistant_service(service_hash, environ, use_existing)
    service_hash = ServiceDefinitions.set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg("Problem with service hash", service_hash) if service_hash.is_a?(FalseClass)
    existing = match_service_to_existing(service_hash, use_existing)
    if existing.is_a?(Hash)
      service_hash = existing
      service_hash[:shared] = true
      @first_build = false
      #  LAREADY DONE service_hash = use_orphan(service_hash) if @service_manager.match_orphan_service(service_hash) == true
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
    return true
  end

  def match_service_to_existing(service_hash, use_existing)
    return false if use_existing.nil?

    use_existing.each do |existing_service|
      p :create_type
      p existing_service[:create_type]
      next if existing_service[:create_type] == 'new'
      next if existing_service[:create_type].nil?
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
   return false
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

end