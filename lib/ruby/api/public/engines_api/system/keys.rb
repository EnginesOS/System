module PublicApiSystemKeys
  def get_user_public_key
    @system_api.get_user_public_key
  end

  def generate_engines_user_ssh_key
    @system_api.generate_engines_user_ssh_key
  end

  def update_user_public_key(key)
    @system_api.update_user_public_key(key)
  end

  def get_ms_public_key
    @system_api.get_ms_public_key
  end

  def set_ms_public_key(key_data)
    @system_api.set_ms_public_key(key_data)
  end

  def get_system_public_key
    @system_api.get_system_public_key
  end

  def  get_repo_keys_names
    @system_api.get_repo_keys_names
  end
end