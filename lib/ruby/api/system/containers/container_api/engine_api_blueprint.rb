class ContainerApi
  def save_blueprint(blueprint, ca)
    blueprint_r = BlueprintApi.new    
    begin
      blueprint_r.save_blueprint(blueprint, ca)
    rescue
    raise EnginesException.new(error_hash('failed to save blueprint', blueprint_r.last_error))
    end 
  end

  def load_blueprint(ca)
    blueprint_r = BlueprintApi.new
    blueprint = blueprint_r.load_blueprint(ca)
    raise EnginesException.new(error_hash('failed to load blueprint', blueprint_r.last_error)) unless blueprint.is_a?(Hash)
     blueprint
  end

end