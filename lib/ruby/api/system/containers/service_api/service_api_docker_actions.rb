module  ServiceApiDockerActions
  def destroy_container(container)
    super
    @engines_core.clear_service_from_registry(container, :non_persistent)
  end

end