module BuildReport

  def get_build_report(engine_name)
    raise EnginesException.new(error_hash('get_build_report passed nil engine_name', engine_name)) if engine_name.nil?
  c = container_state_dir({c_name: engine_name, c_type: 'app'})
    
    if File.exist?("#{c}/buildreport.txt")
      File.read("#{c}/buildreport.txt")
    else
      raise EnginesException.new(error_hash("No Build Report:#{c}/buildreport.txt"))
    end
  end

  def save_build_report(container, build_report)
   # STDERR.puts('Build Resport ' + build_report.to_s)
    f = File.new("#{container_state_dir(container)}/buildreport.txt", File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.puts(build_report)
    ensure
      f.close
    end
    true
  end

end