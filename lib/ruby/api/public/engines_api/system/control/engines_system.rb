module PublicApiSystemControlEnginesSystem
  def update_engines_system_software
    @core_api.update_engines_system_software
  rescue StandardError => e
    handle_exception(e)
  end

  def recreate_engines_system_service
    @core_api.recreate_engines_system_service
  rescue StandardError => e
    handle_exception(e)
  end

  def restart_engines_system_service
    @core_api.restart_engines_system_service
  rescue StandardError => e
    handle_exception(e)
  end

  def dump_heap_stats
    @core_api.dump_heap_stats
  rescue StandardError => e
    handle_exception(e)
  end

  def is_token_valid?(token, ip =nil)
    @core_api.is_token_valid?(token, ip =nil)
  rescue StandardError => e
    handle_exception(e)
  end

end