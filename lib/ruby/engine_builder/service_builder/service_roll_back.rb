module ServiceRollBack
  def service_roll_back
    @attached_services.each do |service_hash|
      if service_hash[:shared]
        rollback_shared_service(service_hash)
      elsif service_hash[:freed_orphan]
        roll_back_orphan(service_hash)
      elsif service_hash[:fresh] = true
        roll_back_new_service(service_hash)
      end
    end
    true
    rescue StandardError => e
      log_exception(e)
  end

  def roll_back_new_service(service_hash)
    service_hash[:remove_all_data] = 'all'
    @core_api.dettach_service(service_hash)
  end

  def roll_back_orphan(service_hash)
    @core_api.rollback_orphaned_service(service_hash)
  end

  def roll_back_shared(service_hash)
    @core_api.roll_back_shared(service_hash)
  end
end