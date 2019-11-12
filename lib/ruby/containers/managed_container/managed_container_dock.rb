module ManagedContainerDock

  def clear_to_save
    @container_dock = nil
    @last_result = nil
    @container_mutex = nil
    @builder = nil
    @store = nil
    expire_engine_info
  end

  def save_blueprint blueprint
    container_dock.save_blueprint(blueprint, store_address)
  end

  def accepts_stream?
    false
  end

  def provides_stream?
    false
  end

  def run_cronjob(cronjob)
    container_dock.run_cronjob(cronjob, self)
  end
end
