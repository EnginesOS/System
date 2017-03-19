module PublicApiSystemControlBaseOS
  def update_base_os
    @system_api.update_base_os
  end

  def restart_base_os
    @system_api.restart_base_os
  end

  def halt_base_os
    @system_api.halt_base_os
  end

end

