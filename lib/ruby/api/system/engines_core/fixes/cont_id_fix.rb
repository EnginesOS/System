module ContFsIdFix
  def fix_containers_fsid()
    engines = getManagedEngines()
    @service_manager.fix_containers_fsid(engines)
  end
end