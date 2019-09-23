module EngineApiImageActions
  def delete_image(container)
    clear_error
    @system_api.rm_engine_from_cache(container.container_name)
    #   volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    @docker_api.delete_image(container, true) if @docker_api.image_exist?(container.image)
    #  @system_api.delete_container_configs(volbuilder, container)
    #    # only delete if del all otherwise backup
    #    # NO Image well delete the rest
    #return @system_api.delete_container_configs(volbuilder, container) unless @docker_api.image_exist?(container.image)
  end
end