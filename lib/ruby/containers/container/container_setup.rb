module ContainerSetup
  def set_running_user
    @cont_user_id = running_user if @cont_user_id.nil? || @cont_user_id == -1
  end

  def post_load
    expire_engine_info
    set_cont_id
    set_running_user
  ensure
    domain_name = SystemConfig.internal_domain
    lock_values
  end
end