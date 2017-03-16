module PublicApiSystemKeys
  def get_public_key
    @system_api.get_public_key
  rescue StandardError => e
    handle_exception(e)
  end

  def generate_engines_user_ssh_key
    @system_api.generate_engines_user_ssh_key
  rescue StandardError => e
    handle_exception(e)
  end

  def update_public_key(key)
    STDERR.puts("KEY " + key.to_s)
    @system_api.update_public_key(key)
  rescue StandardError => e
    handle_exception(e)
  end

end