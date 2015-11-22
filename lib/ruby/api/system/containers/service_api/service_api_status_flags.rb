module ServiceApiStatusFlags
  def has_service_started?(service_name)
    completed_flag_file = SystemConfig.RunDir + '/services/' + service_name + '/run/flags/startup_complete'
    File.exist?(completed_flag_file)
  end
end