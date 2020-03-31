module PublicApiSystemFirstRun
  def set_first_run_parameters(p)
    core.set_first_run_parameters(p)
  end

  def first_run_complete(install_mgmt)
    system_api.first_run_complete(install_mgmt)
  end
end
