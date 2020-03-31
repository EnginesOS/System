module ServiceRollBack
  def service_roll_back
    @attached_services.each do |service_hash|
      if service_hash[:shared].is_a?(TrueClass)
        rollback_shared_service(service_hash)
      elsif service_hash[:freed_orphan].is_a?(TrueClass)
        roll_back_orphan(service_hash)
      elsif service_hash[:fresh] = true
        roll_back_new_service(service_hash)
      end
    end
  end

  private

  def roll_back_new_service(service_hash)
    service_hash[:remove_all_data] = 'all'
    service_hash[:force] = true
   # STDERR.puts('ROLL BACK ' + service_hash.to_s)
    core.dettach_service(service_hash)
  end

  def roll_back_orphan(service_hash)
    #STDERR.puts('Orphan ROLL BACK ' + service_hash.to_s)
    core.rollback_orphaned_service(service_hash)
  end

  def roll_back_shared(service_hash)
   # STDERR.puts('Shared ROLL BACK ' + service_hash.to_s)
    core.roll_back_shared(service_hash)
  end
end
