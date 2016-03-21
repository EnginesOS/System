module EngineApiImageActions
  def delete_image(container)
    clear_error
    @system_api.delete_engine(container)
    return  ContainerStateFiles.delete_container_configs(container) if test_docker_api_result(@docker_api.delete_image(container))
    # only delete if del all otherwise backup
    # NO Image well delete the rest
    return ContainerStateFiles.delete_container_configs(container) unless test_docker_api_result(@docker_api.image_exist?(container.image))
    log_error_mesg("Image Still exists" + container)
  rescue StandardError => e
    log_exception(e)
  end
end