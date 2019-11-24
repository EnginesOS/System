module ContainerSetup
  def set_running_user
    self.cont_user_id = running_user if cont_user_id.nil? || cont_user_id == -1
  end

  def post_load
    expire_engine_info
    self.id = read_container_id if id.nil? 
    set_running_user
    self
  ensure
    self.domain_name = SystemConfig.internal_domain
    lock_values
  end
end
