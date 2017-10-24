module PublicApiBuilder
  def last_build_params
    SystemStatus.last_build_params
  end

  def last_build_log
    if File.exists?(SystemConfig.BuildOutputFile)
      File.read(SystemConfig.BuildOutputFile)
    else
      'none'
    end
  end

  def build_status
    SystemStatus.build_status
  end

  def current_build_params
    SystemStatus.current_build_params
  end

  #writes stream from build.out to out
  #returns 'OK' of FalseClass (latter BuilderApiError
  def follow_build(out)
    build_log_file =  File.new(SystemConfig.BuildOutputFile, 'r')
    while
      begin
        bytes = build_log_file.read_nonblock(100)
        bytes.gsub!(/[\x80-\xFF]/n,'')
      rescue IO::WaitReadable
        retry
      rescue EOFError
        out.write(bytes.force_encoding(Encoding::UTF_8))
        'OK'
        build_log_file.close
      rescue => e
        out.write(bytes)
        build_log_file.close
        'Maybe ' + e.to_s
      end
      out.write(bytes.force_encoding(Encoding::UTF_8))
    end
  end

end
