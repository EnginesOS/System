module ManagedContainerApi
#  def save_state()
#    container_api.save_container(self.dup)
#  end

  def clear_to_save    
    @container_api = nil
    @last_result = nil
    @container_mutex = nil
    @builder = nil
    expire_engine_info
  end

  def save_blueprint blueprint
    container_api.save_blueprint(blueprint, store_address)
  end

  def accepts_stream?
    false
  end

  def provides_stream?
    false
  end

  def run_cronjob(cronjob)
    container_api.run_cronjob(cronjob, self)
  end
end
