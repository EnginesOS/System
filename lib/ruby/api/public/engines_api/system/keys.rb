module PublicApiSystemKeys
  def get_public_key
    @system_api.get_public_key
  end

  def generate_engines_user_ssh_key
    @system_api.generate_engines_user_ssh_key
  end

  def update_public_key(key)
    STDERR.puts("KEY " + key.to_s)
    @system_api.update_public_key(key)
  end

end