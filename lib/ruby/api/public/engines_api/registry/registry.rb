module PublicApiRegistry
  def get_orphaned_services_tree
    @service_manager.get_orphaned_services_tree
  end

  def managed_service_tree
    @service_manager.managed_service_tree
  end

  def get_managed_engine_tree
   @service_manager.get_managed_engine_tree
  end

  def get_configurations_tree
    @service_manager.service_configurations_tree
  end

  def get_shares_tree
   @service_manager.shares_tree
  end
end