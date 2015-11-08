module RollBack
  def rollback
  
  @attached_services.each do |service_hash|    
       if service_hash[:shared]
         roll_back_shared(service_hash)
       elsif service_hash[:freed_orphan]
         roll_back_orphan(service_hash)
       elsif service_hash[:fresh] = true        
         roll_back_new_service(service_hash)         
       end
  end
end
  
  def roll_back_new_service(service_hash)
    service_hash[:remove_all_data] = true
    @core_api.service_manager.delete_service(service_hash) 
  end
  
  def roll_back_orphan(service_hash)
    @core_api.service_manager.rollback_orphaned_service(service_hash)
  end
  
  def roll_back_shared(service_hash)
    return
  end
end