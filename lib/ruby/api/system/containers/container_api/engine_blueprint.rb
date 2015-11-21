module EngineBlueprint
  
  def save_blueprint(blueprint, container)
    blueprint_r = BlueprintApi.new
    log_error_mesg('failed to save blueprint', blueprint_r.last_error) unless blueprint_r.save_blueprint(blueprint, container)
    return true
  end

  def load_blueprint(container)
    blueprint_r = BlueprintApi.new
    blueprint = blueprint_r.load_blueprint(container)
    log_error_mesg('failed to load blueprint', blueprint_r.last_error) unless blueprint.is_a?(Hash)
    return blueprint
  end

end