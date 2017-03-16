module  ServiceApiDockerActions
  def destroy_container(container)
    r = super
    return r unless r == true
    @engines_core.clear_service_from_registry(container, :non_persistent)
  end

end