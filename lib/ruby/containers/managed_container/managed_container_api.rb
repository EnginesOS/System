module ManagedContainerApi
  def save_state()
    status
    c = self.dup
    @container_api.save_container(c)
  end

  def clear_to_save
    @container_api = nil
    @last_result = nil
    @container_mutex = nil
    expire_engine_info
  end

  def save_blueprint blueprint
    @container_api.save_blueprint(blueprint, self)
  end

  def run_cronjob(cronjob)
    @container_api.run_cronjob(cronjob, self)
  end
end