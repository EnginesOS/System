module ManagedContainerApi
  def save_state()
    return false unless has_api?
    c = self.dup
    c.expire_engine_info
   # info = @docker_info_cache
  #  @docker_info_cache = false
    @container_api.save_container(c)
  #  @docker_info_cache = info
    return true
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

end