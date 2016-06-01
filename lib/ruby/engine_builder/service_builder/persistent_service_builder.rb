module PersistantServiceBuilder
  def create_persistent_services(services, environ, use_existing)
    SystemDebug.debug(SystemDebug.builder,:services ,services)
    STDERR.puts('Match persisten sevi3e' + use_existing.to_s)
    services.each do | service_hash |
      SystemDebug.debug(SystemDebug.builder,:servicer_hash,service_hash)
   #   service_hash =  SystemUtils.deal_with_jason(sh)
      STDERR.puts('persisten sevi3e' + service_hash.to_s)
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
      return log_error_mesg('no matching service definition',self) if service_def.nil?
      if service_def[:persistent]
        service_hash[:persistent] = true
        return false unless process_persistent_service(service_hash, environ, use_existing)
      end
    end
    return true
  end

  def process_persistent_service(service_hash, environ, use_existing)
    
    service_hash = ServiceDefinitions.set_top_level_service_params(service_hash, @engine_name)
    return log_error_mesg("Problem with service hash", service_hash) if service_hash.is_a?(FalseClass)
    existing = match_service_to_existing(service_hash, use_existing)
    if existing.is_a?(Hash)
      # service_hash
      service_hash[:shared] = true
      service_hash[:fresh] = false
      @first_build = false
      return attach_existing_service_to_engine(service_hash, existing)

      #  LAREADY DONE service_hash = use_orphan(service_hash) if @service_manager.match_orphan_service(service_hash) == true
    elsif @core_api.match_orphan_service(service_hash) == true #auto orphan pick up
      service_hash = use_orphan(service_hash)
      @first_build = false
    elsif @core_api.service_is_registered?(service_hash) == false
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
    SystemDebug.debug(SystemDebug.builder,:builder_attach_service, service_hash)
    @templater.fill_in_dynamic_vars(service_hash)

    constants = SoftwareServiceDefinition.service_constants(service_hash)
    environ.concat(constants)
    environ.concat(SoftwareServiceDefinition.service_environments(service_hash))
    SystemDebug.debug(SystemDebug.builder, :with_env, service_hash)
    # FIXME: release orphan should happen latter unless use reoprhan on rebuild failure
    if @core_api.create_and_register_service(service_hash)
      @attached_services.push(service_hash)
    else
      return log_error_mesg('Core Failed to attach Service ' , service_hash)
    end
    return true
  end

  def match_service_to_existing(service_hash, use_existing)
    return false if use_existing.nil?
    return log_error_mesg(" Existing Attached services should be an array",use_existing) unless use_existing.is_a?(Array)
    use_existing.each do |existing_service|
      STDERR.puts('Match persisten sevi3e' + existing_service.to_s)
      SystemDebug.debug(SystemDebug.builder, :create_type, existing_service)
      next if existing_service[:create_type] == 'new'
      next if existing_service[:create_type].nil?
      SystemDebug.debug(SystemDebug.builder, existing_service[:type_path] + " and " + service_hash[:type_path], existing_service[:publisher_namespace] + " and " + service_hash[:publisher_namespace])
      if existing_service[:publisher_namespace] == service_hash[:publisher_namespace]\
      && existing_service[:type_path] == service_hash[:type_path]
        SystemDebug.debug(SystemDebug.builder, :comparing_services)
        # FIX ME run a check here on service hash
        return use_active_service(service_hash, existing_service) if existing_service[:create_type] == 'active'
        return use_orphan(existing_service) if existing_service[:create_type] == 'orphan'
      end
    end
    return false
  end

  def use_active_service(service_hash, existing_service )
    s = @core_api.get_service_entry(existing_service)

    s[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    s[:fresh] = false
    s[:shared] = true
    SystemDebug.debug(SystemDebug.builder, :usering_active_Serviec, s)
    return s
  end

  def attach_existing_service_to_engine(service_hash, existing)
    params =  service_hash.dup
    params[ :existing_service] = existing
    trim_to_editable_variables(params)
    if @core_api.attach_existing_service_to_engine(params)
      @attached_services.push(service_hash)
      return true
    end
    return log_error_mesg('failed to attach_existing_service_to_engine(params)',params)
  end

  def trim_to_editable_variables(params)
    variables = SoftwareServiceDefinition.consumer_params(params)
    variables.values do |variable |
      p :variable
      
      p  variable
      key = variable[:name]
      params[:variables].delete(key) if variable[:immutable] == true
    end
    rescue StandardError => e
    log_exception(e,params,variables)
  end
end