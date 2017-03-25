module OrphansServiceBuilder
  def use_orphan(service_hash)
    build_vars = service_hash.dup
    SystemDebug.debug(SystemDebug.orphans,:attaching_orphan, service_hash)
    service_hash = @core_api.retrieve_orphan(service_hash)
    SystemDebug.debug(SystemDebug.orphans, :retrieved_orphan, service_hash)
    STDERR.puts('USE ORPHAN;' + service_hash.to_s)
    @orphans.push(service_hash.dup)
    SystemDebug.debug(SystemDebug.orphans,'@orphans" ',@orphans)
    service_hash[:fresh] = false
    reparent_orphan(service_hash)
  unless service_hash.nil? || build_vars[:variables].nil?
      SystemDebug.debug(SystemDebug.orphans, :from_reparent, service_hash)
      SystemDebug.debug(SystemDebug.orphans, :from_reparent, build_vars)
      service_hash[:variables][:engine_path] = build_vars[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    end
    return service_hash
    rescue StandardError => e
      log_exception(e)
  end

  def reparent_orphan(service_hash)
    STDERR.puts('REPA ORPHAN;' + service_hash.to_s)
    @core_api.reparent_orphan(service_hash, @engine_name)  
  end

  def release_orphans()
    STDERR.puts('RELEASE ORPHANS;')
    @orphans.each do |service_hash|
      service_hash[:remove_all_data] = 'all'
        STDERR.puts('RELEASE ORPHAN;' + service_hash.to_s)
      @core_api.release_orphan(service_hash)
    end
  end
end