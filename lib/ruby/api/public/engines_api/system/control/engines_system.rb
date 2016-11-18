module PublicApiSystemControlEnginesSystem
  def update_engines_system_software
  @core_api.update_engines_system_software
  end
  def restart_engines_system
  @core_api.restart_engines_system
  end
  def recreate_mgmt
  @core_api.recreate_mgmt
  end
  def dump_heap_stats
    @core_api.dump_heap_stats
  end
end