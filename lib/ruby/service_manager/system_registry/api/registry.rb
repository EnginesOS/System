module Registry
  # @ Return complete system registry tree
  def system_registry_tree
    rest_get('tree', nil)
  end

end