module EngineApiBlueprint
  def save_blueprint(blueprint, container)
    blueprint_r = BlueprintApi.new
    raise EnginesException.new(error_hash('failed to save blueprint', blueprint_r.last_error)) unless blueprint_r.save_blueprint(blueprint, container)
  end

  def load_blueprint(container)
    blueprint_r = BlueprintApi.new
    blueprint = blueprint_r.load_blueprint(container)
    raise EnginesException.new(error_hash('failed to load blueprint', blueprint_r.last_error)) unless blueprint.is_a?(Hash)
     blueprint
  end

end