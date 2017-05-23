module ManagedServiceApi
  def save_state()
    return false unless has_api?
    @container_api.save_container(self.dup)
  end
end