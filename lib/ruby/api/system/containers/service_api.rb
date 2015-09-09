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

  def create
    SystemUtils.execute_command('/opt/engines/scripts/setup_service_dir.sh ' + container_name)
    super
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
    ContainerStateFiles.container_state_dir(container) + '/services/'
  end
  
  def retrieve_configurator(c, params)    
     return log_error_mesg('service not running ',params) if c.is_running? == false
     return log_error_mesg('service missing cont_userid ',params) if c.check_cont_uid == false
     cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
     result = SystemUtils.execute_command(cmd)
     if result[:result] == 0
       variables = SystemUtils.hash_string_to_hash(result[:stdout])
       params[:variables] = variables
       return params
     end
     log_error_mesg('Failed retrieve_configurator',result)
     return {}
   end
   
end
