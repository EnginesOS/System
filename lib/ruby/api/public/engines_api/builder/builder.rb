class PublicApi 
  def last_build_params
    SystemStatus.last_build_params
  end

  def last_build_log
    SystemConfig.last_build_log
  end

  def build_status
    SystemStatus.build_status
  end

  def current_build_params
    SystemStatus.current_build_params
  end

  #writes stream from build.out to out
  #returns 'OK' of FalseClass (latter BuilderApiError
  def follow_build(out)
    SystemConfig.follow_build(out)    
  end

  def resolve_blueprint(blueprint_url)
    require '/opt/engines/lib/ruby/api/system/blueprint_api.rb'
    BlueprintApi.perform_inheritance_f(blueprint_url)
  end
end
