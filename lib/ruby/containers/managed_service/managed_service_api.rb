module ManagedServiceApi
  def save_state()
    status
    @container_api.save_container(self.dup)
  end
end