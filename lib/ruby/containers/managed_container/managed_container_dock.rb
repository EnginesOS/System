module ManagedContainerDock

  def save_blueprint(blueprint)
    container_dock.save_blueprint(blueprint, self)
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
