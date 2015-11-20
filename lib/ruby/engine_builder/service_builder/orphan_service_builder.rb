module OrphansServiceBuilder

def use_orphan(service_hash)
   p :attaching_orphan
    p service_hash
   service_hash = @core_api.retrieve_orphan(service_hash)
   p :retrieved_orphan
    p service_hash
   @orphans.push(service_hash.dup) 
    service_hash[:fresh] = false   
    reparent_orphan(service_hash)
    unless service_hash.nil? 
      p :from_reparemt
      p service_hash
      service_hash[:variables][:engine_path] = service_hash[:variables][:engine_path] if service_hash[:type_path] == 'filesystem/local/filesystem'     
    end
      return service_hash
 end
 
 def reparent_orphan(service_hash)   
   service_hash[:old_parent] =  service_hash[:parent_engine]
   service_hash[:parent_engine] = @engine_name
   service_hash[:fresh] = false      
   service_hash[:freed_orphan] = true    
   #resuse_service_hash = @service_manager.reparent_orphan(service_hash)
   return service_hash
 end

 def release_orphans()
   @orphans.each do |service_hash|
     @core_api.release_orphan(service_hash)
   end
 end
end