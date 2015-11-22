module ManagedContainerApi
  def save_state()
    return false unless has_api?
    info = @docker_info_cache
    @docker_info_cache = false
    @container_api.save_container(self)
    @docker_info_cache = info
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

end