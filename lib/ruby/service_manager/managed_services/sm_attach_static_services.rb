module SmAttachStaticServices
  # @returns boolean
  # load persistent and non persistent service definitions off disk and registers them
  def load_and_attach_static_services(dirname, container)
    container.environments  = [] if container.environments.nil?
    curr_service_file = ''
   # SystemDebug.debug(SystemDebug.services, :Globbing, container.container_name, dirname + '/*.yaml')
    service_files = Dir.glob(dirname + '/*.yaml').sort
    service_files.each do |service_file|

      curr_service_file = service_file
     # SystemDebug.debug(SystemDebug.services,:Service_dile, container.container_name, curr_service_file)

      yaml = File.read(service_file)
      service_hash = YAML::load(yaml)
      service_hash = symbolize_keys(service_hash)
      service_hash[:container_type] = container.ctype
     # SystemDebug.debug(SystemDebug.services, :loaded_service_hash, service_hash)
      set_top_level_service_params(service_hash, container.container_name)
      if service_hash.has_key?(:shared_service) == false || service_hash[:shared_service] == false
        templater =  Templater.new(container)
        templater.proccess_templated_service_hash(service_hash)
       # SystemDebug.debug(SystemDebug.services, :templated_service_hash, service_hash)
       # SystemDebug.debug(SystemDebug.services, 'is registreed ', system_registry_client.service_is_registered?(service_hash))
        if service_hash[:persistent] == false ||  system_registry_client.service_is_registered?(service_hash) == false
         # SystemDebug.debug(SystemDebug.services,  :creating_static, service_hash)
          begin
            create_and_register_service(service_hash)
          rescue StandardError => e
           #continue and add env vars if duplicate all will procede otherwise get_service_entry will trip an Exception
          end
        else
         # SystemDebug.debug(SystemDebug.services, :attaching, service_hash)
          service_hash = get_service_entry(service_hash)
        end
      else
        service_hash = get_service_entry(service_hash)
      end
      if service_hash.is_a?(Hash) && service_hash.key?(:variables)
       # SystemDebug.debug(SystemDebug.services, :post_entry_service_hash, service_hash)
        new_envs = SoftwareServiceDefinition.service_environments(service_hash)
      #  STDERR.puts('NEW ENVS ' + new_envs.to_s +  ' from ' + service_hash.to_s)
        EnvironmentVariable.merge_envs(new_envs, container.environments) unless new_envs.nil?
      end

    end
    true
  end

end
