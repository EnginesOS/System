class ServiceBuilder < ErrorsApi
  def use_orphan(service_hash)
    build_vars = service_hash.dup
    service_hash = core.retrieve_orphan(service_hash)
    @orphans.push(service_hash.dup)
    service_hash[:fresh] = false
    reparent_orphan(service_hash)
    unless service_hash.nil? || build_vars[:variables].nil?
      service_hash[:variables][:engine_path] = build_vars[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'
    end
    service_hash
  end

  def reparent_orphan(service_hash)
  #  STDERR.puts('REparent ' + service_hash.to_s)
    core.reparent_orphan(service_hash, @engine_name)
  end

  def release_orphans()
    @orphans.each do |service_hash|
     # STDERR.puts('releasing_orphan ' + service_hash.to_s)
      core.release_orphan(service_hash)
     # STDERR.puts('released_orphan ' + service_hash.to_s)
    end
  end
end
