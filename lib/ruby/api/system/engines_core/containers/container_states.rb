class EnginesCore
  def get_engines_states
    system_api.get_engines_states
  end

  def get_services_states
    system_api.get_services_states
  end

  def user_clear_error(container)
    container.user_clear_error
  end
end