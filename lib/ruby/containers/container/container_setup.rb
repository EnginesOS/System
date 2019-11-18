module ContainerSetup
  def set_running_user
    cont_user_id = running_user if cont_user_id.nil? || cont_user_id == -1
  end

  def post_load
    expire_engine_info
    id = read_container_id if id.nil? || id == -1
    set_running_user
    self
  ensure
    domain_name = SystemConfig.internal_domain
    lock_values
  end
end
