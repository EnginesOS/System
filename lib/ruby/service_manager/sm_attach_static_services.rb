module SmAttachStaticServices
  #@returns boolean
  #load persistent and non persistent service definitions off disk and registers them
  def load_and_attach_services(dirname,container)
    clear_error
    container.environments  = [] if container.environments .nil?
    curr_service_file = ''
    SystemDebug.debug(SystemDebug.services,:Globbing,container.container_name,dirname + '/*.yaml')    
    Dir.glob(dirname + '/*.yaml').each do |service_file|
      curr_service_file = service_file
      SystemDebug.debug(SystemDebug.services,:Service_dile,container.container_name,curr_service_file)    

      yaml = File.read(service_file)
      service_hash = YAML::load(yaml)
      service_hash = SystemUtils.symbolize_keys(service_hash)
      service_hash[:container_type] = container.ctype
      SystemDebug.debug(SystemDebug.services, :loaded_service_hash, service_hash)
      ServiceDefinitions.set_top_level_service_params(service_hash, container.container_name)
      if service_hash.has_key?(:shared_service) == false || service_hash[:shared_service] == false
        templater =  Templater.new(@core_api.system_value_access,container)
        templater.proccess_templated_service_hash(service_hash)
        SystemDebug.debug(SystemDebug.services, :templated_service_hash, service_hash)

        if service_hash[:persistent] == false || test_registry_result(system_registry_client.service_is_registered?(service_hash)) == false
          SystemDebug.debug(SystemDebug.services,  :creating_static, service_hash)
          create_and_register_service(service_hash)
        else
          SystemDebug.debug(SystemDebug.services, :attaching, service_hash)
          service_hash =  test_registry_result(system_registry_client.get_service_entry(service_hash))
        end
      else
        # p :finding_service_to_share
        #  p service_hash
        service_hash = test_registry_result(system_registry_client.get_service_entry(service_hash))
        #   p :load_share_hash
        #   p service_hash
      end
      if service_hash.is_a?(Hash)
        SystemDebug.debug(SystemDebug.services, :post_entry_service_hash, service_hash)
        
        new_envs = SoftwareServiceDefinition.service_environments(service_hash)
        # p 'new_envs'
        # p new_envs.to_s

        envs = EnvironmentVariable.merge_envs(new_envs,container.environments ) unless new_envs.nil?
        # envs.concat(new_envs) if !new_envs.nil?
      else
        log_error_mesg('failed to get service entry from ' ,service_hash)
      end
    end
     true
  rescue StandardError =>e
    puts e.message
    log_error_mesg('Parse error on ' + curr_service_file,container)
    log_exception(e)
  end

end