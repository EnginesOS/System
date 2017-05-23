module ManagedContainerApi
  def save_state()
    return false unless has_api?
    c = self.dup 
   # c.volume_service_builder = false
    @container_api.save_container(c)
  end

  def clear_to_save
    @container_api = nil
    @last_result = nil
    @container_mutex = nil
    expire_engine_info
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

  def run_cronjob(cronjob)
    return false unless has_api?
    @container_api.run_cronjob(cronjob, self)
  end
end