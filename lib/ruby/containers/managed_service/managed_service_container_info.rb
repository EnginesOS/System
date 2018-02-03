module ManagedServiceContainerInfo
  def check_cont_uid
    if @cont_user_id.nil? || @cont_user_id == false  || @cont_user_id == ''
      @cont_user_id = running_user
      if @cont_user_id.nil? || @cont_user_id == false
        raise EnginesException.new(error_hash('service missing cont_user_id ', @container_name))
      end
    end
    true
  end

  def is_privileged?
    if @privileged == true
      true
    else
      false
    end
  end
end