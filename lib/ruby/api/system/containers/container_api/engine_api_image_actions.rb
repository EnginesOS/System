module EngineApiImageActions
  def delete_image(container)
    clear_error
    @system_api.delete_engine(container)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    @docker_api.delete_image(container) if @docker_api.image_exist?(container.image)
    ContainerStateFiles.delete_container_configs(volbuilder, container)
    #    # only delete if del all otherwise backup
    #    # NO Image well delete the rest
    #return ContainerStateFiles.delete_container_configs(volbuilder, container) unless @docker_api.image_exist?(container.image)
  end
end