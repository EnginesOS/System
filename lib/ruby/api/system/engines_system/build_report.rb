module BuildReport
  def get_build_report(engine_name)
    clear_error
    return log_error_mesg('get_build_report passed nil engine_name', engine_name ) if engine_name.nil?
    state_dir = SystemConfig.RunDir + '/containers/' + engine_name
    return File.read(state_dir + '/buildreport.txt') if File.exist?(state_dir + '/buildreport.txt')
     log_error_mesg('Build Not Successful')
  rescue StandardError => e
    log_exception(e)
  end

  def save_build_report(container, build_report)
    clear_error
    state_dir = ContainerStateFiles.container_state_dir(container)
    f = File.new(state_dir  + '/buildreport.txt', File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(build_report)
    f.close
     true
  rescue StandardError => e
   log_exception(e)
  end

end