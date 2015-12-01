module ContainerSetup
  def set_running_user
    @cont_userid = running_user if @cont_userid.nil? || @cont_userid == -1
  end

  def post_load
    expire_engine_info
    set_running_user
    set_cont_id
    lock_values
  end
end