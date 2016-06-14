module ContainerSetup
  def set_running_user
    @cont_userid = running_user if @cont_userid.nil? || @cont_userid == -1
  end

  def post_load
    STDERR.puts(@mapped_ports.to_s)
    expire_engine_info
    set_cont_id
    set_running_user
    lock_values
  end
end