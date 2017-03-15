module EngineApiImageActions
  def delete_image(container)
    clear_error
    @system_api.delete_engine(container)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    return ContainerStateFiles.delete_container_configs(volbuilder, container) unless @docker_api.image_exist?(container.image)
    return ContainerStateFiles.delete_container_configs(volbuilder, container) if @docker_api.delete_image(container)
    #    # only delete if del all otherwise backup
    #    # NO Image well delete the rest
    #return ContainerStateFiles.delete_container_configs(volbuilder, container) unless @docker_api.image_exist?(container.image)
    log_error_mesg("Image Still exists" + container)
  rescue StandardError => e
    log_exception(e)
  end
end