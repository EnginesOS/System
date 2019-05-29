module ContainerFixes
  def fix_containers_fsid
    @engines_api.fix_containers_fsid(getManagedEngines)
  end
end