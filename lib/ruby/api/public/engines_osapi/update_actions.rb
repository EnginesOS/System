module UpdateActions
  def update_engines_system_software
    return success('System', @core_api.last_error) if @core_api.update_engines_system_software
    failed('System', @core_api.last_error, 'Engines System Updating')
  end

  def update_system
    return success('System', 'System Updating') if @core_api.update_system
    failed('System', 'not permitted', 'Updating')
  end

  # calls api to run system update
  # @return EnginesOSapiResult
  def system_update
    return success('System Update', "OK") if @core_api.system_update
    failed('System Update', @core_api.last_error, 'Update')
  end

end