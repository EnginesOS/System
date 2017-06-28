module PublicApiSystemControlEnginesSystem
  def update_engines_system_software
    @core_api.update_engines_system_software
  end

  def recreate_engines_system_service
    @core_api.recreate_engines_system_service
  end

  def restart_engines_system_service
    @core_api.restart_engines_system_service
  end

  def dump_heap_stats
    @core_api.dump_heap_stats
  end

  def is_token_valid?(token, ip =nil)
    @core_api.is_token_valid?(token, ip = nil)
  end
  
  def dump_threads
    r = ''
    Thread.list.each do |thread|
      r += thread.to_s + ' ' + thread.status
      r += thread[:name] if thread.key?(:name)
      r += "\n"
  end
  r
  end
end