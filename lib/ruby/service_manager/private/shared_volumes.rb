def attach_shared_volume(shared_service)
  engine = @core_api.loadManagedEngine(shared_service[:parent_engine])
  #used by the builder whn no engine to add volume to def
  return engine unless  engine.is_a?(ManagedEngine)
  # Volume.complete_service_hash(shared_service)
  true
  rescue StandardError => e
    handle_exception(e, shared_service)
end

#def dettach_shared_volume(service_hash)
#  engine = @core_api.loadManagedEngine(service_hash[:parent_engine])
#  return engine unless engine.is_a?(ManagedEngine)
#
#  engine.del_volume(service_hash)
#end