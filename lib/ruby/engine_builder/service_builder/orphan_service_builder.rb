module OrphansServiceBuilder
  def use_orphan(service_hash)
    SystemDebug.debug(SystemDebug.orphans,:attaching_orphan, service_hash)
    service_hash = @core_api.retrieve_orphan(service_hash)
    SystemDebug.debug(SystemDebug.orphans, :retrieved_orphan, service_hash)
    @orphans.push(service_hash.dup)
    SystemDebug.debug(SystemDebug.orphans,'@orphans" ',@orphans)
    service_hash[:fresh] = false
    reparent_orphan(service_hash)
    unless service_hash.nil?
      SystemDebug.debug(SystemDebug.orphans, :from_reparent, service_hash)
      service_hash[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    end
    return service_hash
  end

  def reparent_orphan(service_hash)
    @core_api.reparent_orphan(service_hash, @engine_name)  
  end

  def release_orphans()
    @orphans.each do |service_hash|
      service_hash[:remove_all_data] = false
      @core_api.release_orphan(service_hash)
    end
  end
end