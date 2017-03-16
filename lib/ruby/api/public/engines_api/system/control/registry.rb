module PublicApiSystemControlRegistry
  def force_registry_restart
    @core_api.force_registry_restart
  rescue StandardError => e
    handle_exception(e)
  end
end