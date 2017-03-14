module ManagedServiceContainerInfo
  def check_cont_uid
    if @cont_userid.nil? || @cont_userid == false  || @cont_userid == ''
      @cont_userid = running_user
      if @cont_userid.nil? || @cont_userid == false
        return log_error_mesg('service missing cont_userid ',@container_name)       
      end
    end
     true
  end
end