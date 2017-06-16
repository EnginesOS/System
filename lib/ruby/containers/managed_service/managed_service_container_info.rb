module ManagedServiceContainerInfo
  def check_cont_uid
    if @cont_userid.nil? || @cont_userid == false  || @cont_userid == ''
      @cont_userid = running_user
      if @cont_userid.nil? || @cont_userid == false
        raise EnginesException.new(error_hash('service missing cont_userid ', @container_name))
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