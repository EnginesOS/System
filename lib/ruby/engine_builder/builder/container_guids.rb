module ContainerGuids
  def set_container_guids
    unless set_guids_from_orphan
      unless @build_params[:permission_as].nil?
        @cont_user_id = @core_api.lookup_app_uid(@build_params[:permission_as])
        @data_uid = @core_api.lookup_app_duid(@build_params[:permission_as])
        @data_gid = @core_api.lookup_app_dgid(@build_params[:permission_as])
      else
        @cont_user_id = new_container_uid
        @data_uid = new_data_uid
        @data_gid = new_data_gid
      end
    end
  end

  def set_guids_from_orphan
    r = false
    @build_params[:attached_services].each do |service|
      next unless service[:create_type] == 'orphan'
        r = lookup_ids(service) if service[:create_type] == 'filesystem/local/filesystem'
        break if r == true
    end
    r
  end
  
  def lookup_ids(service)
    r = false
    service_hash = @core_api.retrieve_orphan(service)
   if service_hash.is_a?(Hash)
     if service_hash[:varaibles].is_a?(Hash)     
      @cont_user_id = service_hash[:varaibles][]
      @data_uid = service_hash[:varaibles][:user]
      @data_gid = service_hash[:varaibles][:group]
      r = true
     end
   end
   STDERR.puts('Failed to get ID from orphan ' + service.to_s + "\n retrieved:" + service_hash.to_s) unless r == true
   r
  end
end