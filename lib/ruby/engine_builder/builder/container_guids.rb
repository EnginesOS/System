module ContainerGuids
  #  def new_container_uid
  #    @core_api.new_container_uid(@build_params[:engine_name])
  #  end
  def set_container_guids
    unless set_guids_from_orphan.is_a?(TrueClass)
      unless @build_params[:permission_as].nil?
        @cont_user_id = @core_api.lookup_app_uid(@build_params[:permission_as])
        @data_uid = @core_api.lookup_app_duid(@build_params[:permission_as])
        @data_gid = @core_api.lookup_app_dgid(@build_params[:permission_as])
        STDERR.puts('PERMISSION AS ' + @cont_user_id.to_s + ' ' + @data_uid .to_s)
      else
        STDERR.puts('NEW CONT ID')
        @cont_user_id = @core_api.new_container_uid(@build_params[:engine_name]) #new_container_uid
        @data_uid = new_data_uid(@build_params[:engine_name])
        @data_gid = @core_api.new_data_gid(@build_params[:engine_name])
      end
    end
  end

  private
  def set_guids_from_orphan
    r = false
    @build_params[:attached_services].each do |service|
      next if service[:create_type] == 'share'
      r = lookup_ids(service) if service[:type_path] == 'filesystem/local/filesystem'
      if r == true
        STDERR.puts('Got ids from orphan ' + service.to_s)
        break
      end
    end
    STDERR.puts('Get ids from orphan status' + r.to_s)
    r
  end

  def lookup_ids(service)
    r = false
    service_hash = @core_api.retrieve_orphan(service)
    if service_hash.is_a?(Hash)
      if service_hash[:variables].is_a?(Hash)
        if service_hash[:variables].key?(:fw_user)
          @cont_user_id = service_hash[:variables][:fw_user]
          r = true
        else
          service[:variables][:fw_user] = @core_api.volume_ownership({container_type: service[:container_type],
            container_name: service[:container_name],
            volume_name: service[:service_handle]
          })
          if service[:variables][:fw_user] == '-1' || service[:variables][:fw_user].nil?
            r = false
          else
            r = true
          end
        end
        @data_uid = service_hash[:variables][:user]
        @data_gid = service_hash[:variables][:group]
      end
    end
    STDERR.puts('Failed to get ID from orphan ' + service.to_s + "\n retrieved:" + service_hash.to_s) unless r == true
    r
  rescue
    false
  end
end