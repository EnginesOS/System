module PublicApiRegistry
  def get_orphaned_services_tree
    @service_manager.get_orphaned_services_tree.to_h
  end

  def managed_service_tree
    @service_manager.managed_service_tree.to_h
  end

  def get_managed_engine_tree
   @service_manager.get_managed_engine_tree.to_h
  end

  def get_configurations_tree
    @service_manager.service_configurations_tree.to_h
  end

  def get_shares_tree
   @service_manager.shares_tree.to_h
  end
end