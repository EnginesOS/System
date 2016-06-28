module PublicApiRegistry
  def get_orphaned_services_tree
    as_hash(@service_manager.get_orphaned_services_tree)
  end

  def managed_service_tree
    as_hash(@service_manager.managed_service_tree)
  end

  def get_managed_engine_tree
    as_hash(@service_manager.get_managed_engine_tree)
  end

  def get_configurations_tree
    as_hash( @service_manager.service_configurations_tree)
  end

  def get_shares_tree
    as_hash(@service_manager.shares_tree)
  end
  
  def as_hash(tree)
    h = { }

     h[:name] = tree.name
     h[:content] = tree.content
     h[:children] =  []
    tree.children do |child|
      h[:children].push(as_hash(child))
    end
    h
    end
end