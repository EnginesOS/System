def attach_shared_volume(shared_service)
  #  STDERR.puts(' attach_shared_volume ' + shared_service.to_s)
  begin
  engine = core.loadManagedEngine(shared_service[:service_owner_handle])
  rescue

  end
  true
end
