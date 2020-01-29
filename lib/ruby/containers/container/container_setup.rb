module ContainerSetup
  def set_running_user
    self.cont_user_id = running_user if cont_user_id.nil? || cont_user_id == -1
  end

  def post_load
    STDERR.puts " WETREW WEREWRE" * 5
    expire_engine_info
    STDERR.puts " WETREW WEREWRE" * 10
    self.id = read_container_id if id.nil?
    STDERR.puts " WETREW WEREWRE" * 20
    set_running_user
    STDERR.puts " WETREW WEREWRE" * 30
    self
  ensure
    self.domain_name = SystemConfig.internal_domain
    lock_values
  end
end
