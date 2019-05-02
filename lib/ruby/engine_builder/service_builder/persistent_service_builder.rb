module PersistantServiceBuilder
  def create_persistent_services(services, environ, use_existing)
    SystemDebug.debug(SystemDebug.builder, :services, services)
    services.each do | service_hash |
      SystemDebug.debug(SystemDebug.builder, :servicer_hash, service_hash)
      service_def = software_service_definition(service_hash)
      raise EngineBuilderException.new(error_hash('no matching service definition for ' + service_hash.to_s, self)) if service_def.nil?
      if service_def[:persistent]
        service_hash[:persistent] = true
        process_persistent_service(service_hash, environ, use_existing)
      end
    end
  end

  private

  #ensure service hash has all variables
  def match_variables(service_hash)
    consumer_params = SoftwareServiceDefinition.consumer_params(service_hash)
    consumer_params.keys.each do |cp_key|
      skey = consumer_params[cp_key][:name]
      unless service_hash[:variables].key?(skey)
        STDERR.puts('MISSING service_hash[' + skey.to_s + ']<->consumer_params[:' + cp_key.to_s + '] ' + service_hash[:variables][skey].to_s + ' = ' + consumer_params[cp_key][:value].to_s)
       # service_hash[:variables][skey] = consumer_params[cp_key][:value] unless consumer_params[cp_key][:value].nil?
      end
    end
  end

  def match_service_to_existing(service_hash, use_existing)
    unless use_existing.nil?
      raise EngineBuilderException.new(error_hash(" Existing Attached services should be an array", use_existing)) unless use_existing.is_a?(Array)
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
    end
    false
  end

  def use_active_service(service_hash, existing_service )
    s = @core_api.get_service_entry(existing_service)
    s[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    s[:fresh] = false
    s[:shared] = true
    SystemDebug.debug(SystemDebug.builder, :usering_active_Serviec, s)
    s
  end

  def share_service_to_engine(service_hash, existing)
    SystemDebug.debug(SystemDebug.builder, :share_service_to_engine, service_hash, existing)
    service_hash[:owner] = existing[:parent_engine]
    service_hash[:existing_service] = existing
    if @core_api.connect_share_service(service_hash)
      add_file_service(service_hash) if service_hash[:type_path] == 'filesystem/local/filesystem'
      @attached_services.push(service_hash)
    else
      raise EngineBuilderException.new(error_hash('failed to share_service_to_engine(params)', params))
    end
    true
  end

  def process_persistent_service(service_hash, environ, use_existing)
    SystemDebug.debug(SystemDebug.builder, :service, service_hash)
    service_hash = set_top_level_service_params(service_hash, @engine_name)
    existing = match_service_to_existing(service_hash, use_existing)
    if existing.is_a?(Hash)
      service_hash[:fresh] = false
      @first_build = false
      SystemDebug.debug(SystemDebug.builder, :existing_service, service_hash)
      return share_service_to_engine(service_hash, existing) if existing[:shared] == true
      service_hash = existing #Orphan case
    elsif use_existing.is_a?(TrueClass)
      return @core_api.get_service_entry(service_hash)
    elsif @core_api.match_orphan_service(service_hash) == true #auto orphan pick up
      SystemDebug.debug(SystemDebug.builder, :orphan_service, service_hash)
      service_hash = use_orphan(service_hash)
      @first_build = false
      SystemDebug.debug(SystemDebug.builder, ' use orphan ', service_hash)
    elsif @core_api.service_is_registered?(service_hash) == false
      @first_build = true
      service_hash[:fresh] = true
    else # elseif over attach to existing true attached to existing
      service_hash[:fresh] = false
      raise EngineBuilderException.new(error_hash('Failed to build cannot over write ' + service_hash[:service_handle].to_s + ' Service Found', self))
    end

    # if service_hash[:type_path] == 'filesystem/local/filesystem'
    #   SystemDebug.debug(SystemDebug.builder, :local_file_service, service_hash)
    result = add_file_service(service_hash)  if service_hash[:type_path] == 'filesystem/local/filesystem'
    #  raise EngineBuilderException.new(error_hash('failed to create fs', self)) unless result
    # end
    SystemDebug.debug(SystemDebug.builder, :builder_attach_service, service_hash)

    match_variables(service_hash)
    @templater.fill_in_dynamic_vars(service_hash)
    match_variables(service_hash)
    constants = SoftwareServiceDefinition.service_constants(service_hash)
    environ.concat(constants)
    service_environment = SoftwareServiceDefinition.service_environments(service_hash)
    add_service_env_to_env(environ, service_environment)
    #environ.concat(SoftwareServiceDefinition.service_environments(service_hash))

    SystemDebug.debug(SystemDebug.builder, :with_env, environ)

    @attached_services.push(service_hash)
    @core_api.create_and_register_service(service_hash)
  end

  def add_service_env_to_env(environ, service_env)
    service_env.each do |new_env|
      inc = 1
      environ.each do |env|
        if env.name == new_env.name
          oldname = new_env.name
          STDERR.puts('Dup env name' + new_env.name.to_s)
          new_env.name = oldname.to_s + inc.to_s
          inc += 1
        end
      end
    end
    environ.concat(service_env)
  end

end