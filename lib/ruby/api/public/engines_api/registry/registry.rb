module PublicApiRegistry
  def get_orphaned_services_tree
    @core_api.get_orphaned_services_tree
  rescue StandardError => e
    handle_exception(e)
  end

  def managed_service_tree
    @core_api.managed_service_tree
  rescue StandardError => e
    handle_exception(e)
  end

  def get_managed_engine_tree
    @core_api.get_managed_engine_tree
  rescue StandardError => e
    handle_exception(e)
  end

  def get_configurations_tree
    @core_api.get_configurations_tree
  rescue StandardError => e
    handle_exception(e)
  end

  def get_shares_tree
    @core_api.get_shares_tree
  rescue StandardError => e
    handle_exception(e)
  end
end