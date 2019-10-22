module PublicApiSystemControlEnginesSystem
  def update_engines_system_software
    core.update_engines_system_software
  end

  def recreate_engines_system_service
    core.recreate_engines_system_service
  end

  def restart_engines_system_service
    core.restart_engines_system_service
  end

  def dump_heap_stats
    core.dump_heap_stats
  end

  def is_token_valid?(token, ip =nil)
    core.is_token_valid?(token, ip = nil)
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
