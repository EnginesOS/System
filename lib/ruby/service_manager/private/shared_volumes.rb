def attach_shared_volume(shared_service)
  #  STDERR.puts(' attach_shared_volume ' + shared_service.to_s)
  begin
  engine = @core_api.loadManagedEngine(shared_service[:service_owner_handle])
  rescue
    
  end
  #used by the builder whn no engine to add volume to def
  #  return engine unless engine.is_a?(ManagedEngine)
  # Volume.complete_service_hash(shared_service)
  true
end

#def dettach_shared_volume(service_hash)
#  engine = @core_api.loadManagedEngine(service_hash[:parent_engine])
#  return engine unless engine.is_a?(ManagedEngine)
#
#  engine.del_volume(service_hash)
#end