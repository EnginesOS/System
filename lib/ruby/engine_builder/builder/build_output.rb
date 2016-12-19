module BuildOutput
  def setup_log_output
    SystemDebug.debug(SystemDebug.builder,'setup_log_output ')
    @log_file = File.new(SystemConfig.DeploymentDir + '/build.out', File::CREAT | File::TRUNC | File::RDWR, 0644)
    @err_file = File.new(SystemConfig.DeploymentDir + '/build.err', File::CREAT | File::TRUNC | File::RDWR, 0644)
  rescue StandardError => e
    log_exception(e)
  end

  def log_build_output(line)
    return if line.nil?
    return if line == "\u0000"

    #  line.force_encoding(Encoding::ANSI) # UTF_8)
    @log_file.puts(line)
    @log_file.flush
  rescue StandardError => e
    log_exception(e)
    return
  end

  def log_build_errors(line)
    line = '' if line.nil?
      #    line.force_encoding(Encoding::ANSI) # UTF_8)
    @err_file.puts(line.to_s) unless @err_file.nil?
    log_build_output('ERROR:' + line.to_s)
    @result_mesg = 'Error.' + line.to_s
    @build_error = @result_mesg
    return false
  rescue StandardError => e
    log_exception(e)
    return false
  end

  def add_to_build_output(word)
    @log_file.write(word)
    @log_file.flush
  rescue
    return
  end

  def close_all
    if @log_file.closed? == false
      log_build_output('Build Result:' + @result_mesg)
      log_build_output('Build Finished')
      @log_file.close
    end
    @err_file.close unless @err_file.closed?

    return false
  end

  # used to fill in erro mesg with last ten lines
  def tail_of_build_log
    retval = ''
    lines = File.readlines(SystemConfig.DeploymentDir + '/build.out')
    lines_count = lines.count - 1
    start = lines_count - 10
    for n in start..lines_count
      retval += lines[n].to_s
    end
    return retval + tail_of_build_error_log
  end

  # used to fill in erro mesg with last ten lines
  def tail_of_build_error_log
    retval = ''
    lines = File.readlines(SystemConfig.DeploymentDir + '/build.err')
    lines_count = lines.count - 1
    start = lines_count - 10
    for n in start..lines_count
      retval += lines[n].to_s
    end
    return retval
  rescue
    return retval
  end
end