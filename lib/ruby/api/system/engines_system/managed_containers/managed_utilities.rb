require '/opt/engines/lib/ruby/containers/store/utility_store'

module ManagedUtilities
  def loadManagedUtility(name)
    utility_store.model(name)
  end

  protected

  def utility_store
    Container::UtilityStore.instance
  end
end
