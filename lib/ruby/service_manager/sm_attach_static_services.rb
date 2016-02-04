module SmAttachStaticServices
  #@returns boolean
  #load persistent and non persistent service definitions off disk and registers them
  def load_and_attach_services(dirname,container)
    clear_error
    container.environments  = [] if container.environments .nil?
    curr_service_file = ''
    Dir.glob(dirname + '/*.yaml').each do |service_file|
      curr_service_file = service_file
      yaml = File.read(service_file)
      service_hash = YAML::load( yaml )
      service_hash = SystemUtils.symbolize_keys(service_hash)
      service_hash[:container_type] = container.ctype

      ServiceDefinitions.set_top_level_service_params(service_hash, container.container_name)
      if service_hash.has_key?(:shared_service) == false || service_hash[:shared_service] == false
        templater =  Templater.new(SystemAccess.new,container)
        templater.proccess_templated_service_hash(service_hash)
        SystemUtils.debug_output(  :templated_service_hash, service_hash)
        
        if service_hash[:persistent] == false || test_registry_result(system_registry_client.service_is_registered?(service_hash)) == false
          SystemUtils.debug_output(  :creating_static, service_hash)
          create_and_register_service(service_hash)
        else
          SystemUtils.debug_output( :attaching, service_hash)
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
        SystemUtils.debug_output(  :post_entry_service_hash, service_hash)
        new_envs = SoftwareServiceDefinition.service_environments(service_hash)
        # p 'new_envs'
        # p new_envs.to_s
        envs = EnvironmentVariable.merge_envs(new_envs,container.environments ) unless new_envs.nil?
        # envs.concat(new_envs) if !new_envs.nil?
      else
        log_error_mesg('failed to get service entry from ' ,service_hash)
      end
    end
    return true
  rescue Exception=>e
    puts e.message
    log_error_mesg('Parse error on ' + curr_service_file,container)
    log_exception(e)
  end

end