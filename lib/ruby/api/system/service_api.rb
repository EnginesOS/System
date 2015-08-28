class ServiceApi < ContainerApi
  def get_registered_against_service(params)
    @engines_core.get_registered_against_service(params)
  end

  def service_manager
    @engines_core.service_manager
  end
  #
  #  def load_and_attach_persistant_services(service)
  #    @engines_core.load_and_attach_persistant_services(service)
  #  end

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    @engines_core.pull_image(image_name)
  end

  #  def load_and_attach_shared_services(service)
  #    @engines_core.load_and_attach_shared_services(service)
  #  end

  def load_and_attach_persistant_services(container)
    dirname = container_services_dir(container) + '/pre/'
    @engines_core.service_manager.load_and_attach_services(dirname, container)
  end

  def load_and_attach_shared_services(container)
    dirname = container_services_dir(container) + '/shared/'
    @engines_core.service_manager.load_and_attach_services(dirname, container)
  end

  def load_and_attach_nonpersistant_services(container)
    dirname = container_services_dir(container) + '/post/'
    @engines_core.service_manager.load_and_attach_services(dirname, container)
  end

  def container_services_dir(container)
    @engines_core.container_state_dir(container) + '/services/'
  end
  
  def retrieve_configurator(c, configurator_params)    
     return log_error_mesg('service not running ',configurator_params) if is_running? == false
     return log_error_mesg('service missing cont_userid ',configurator_params) if check_cont_uid == false
     cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + configurator_params[:configurator_name].to_s + '.sh '
     result = SystemUtils.execute_command(cmd)
     if result[:result] == 0
       variables = SystemUtils.hash_string_to_hash(result[:stdout])
       configurator_params[:variables] = variables
       return configurator_params
     end
     log_error_mesg('Failed retrieve_configurator',result)
     return {}
   end
   
end
