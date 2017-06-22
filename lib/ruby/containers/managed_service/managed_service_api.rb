module ManagedServiceApi
  def save_state()
    @container_api.save_container(self.dup)
  end
end