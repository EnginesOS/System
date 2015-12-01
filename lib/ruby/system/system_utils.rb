class SystemUtils
  @@debug=false
  @@level=0

  attr_reader :debug, :level, :last_error
  def SystemUtils.debug_output(label, object = nil)
    STDERR.puts  label.to_s + ":" + object.to_s  if SystemUtils.debug == true
  end

  def SystemUtils.log_output(object, level)
    if SystemUtils.level < level
      STDERR.puts 'Error[' + Process.pid.to_s + ']:'+ object.to_s if level == 10
      puts 'Error ' + object.to_s
    end
    return false
  end

  def SystemUtils.debug_state?
    return @@debug
  end

  #@Logs to passeenger std out the @msg followed by @object.to_s
  #Logs are written to apache/error.log
  # error mesg is truncated to 512 bytes
  # returns nothing
  def SystemUtils.log_error_mesg(msg, object)
    obj_str = object.to_s.slice(0, 512)
    SystemUtils.log_output('ERROR:' + msg.to_s + ':->:' + obj_str ,10)
  end

  def SystemUtils.log_error(object)
    SystemUtils.log_output(object, 10)
  end

  def SystemUtils.get_service_pubkey(service, cmd)
    cmd_line = 'docker exec ' + service + ' /home/get_pubkey.sh ' + cmd
    SystemUtils.run_command(cmd_line)
  end

  def SystemUtils.system_release
    return 'current' if File.exists?(SystemConfig.ReleaseFile) == false
    release = File.read(SystemConfig.ReleaseFile)
    return release.strip
  end

  def SystemUtils.version
    return SystemUtils.system_release + '.' + SystemConfig.api_version + '.' + SystemConfig.engines_system_version
  end

  def SystemUtils.symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
      when String then key.to_sym
      else key
      end
      new_value = case value
      when Hash then symbolize_keys(value)
      when Array   then
        newval = []
        value.each do |array_val|
          if array_val.is_a?(Hash)
            array_val = SystemUtils.symbolize_keys(array_val)
          end
          newval.push(array_val)
        end
        newval
      else value
      end
      result[new_key] = new_value
      result
    }
  end

  def SystemUtils.log_exception(e)
    e_str = e.to_s
    e.backtrace.each do |bt|
      e_str += bt + " \n"
    end
    @@last_error = e_str
    SystemUtils.log_output(e_str, 10)
    e_str +="\n\n"
    elof = File.open("/tmp/exceptions.log","a+")
    elof.write(e_str)
    elof.close
    SystemUtils.log_exception_to_bugcatcher(e) unless File.exists?(SystemConfig.NoRemoteExceptionLoggingFlagFile)

  end

  def SystemUtils.log_exception_to_bugcatcher(e)
    require "net/http"
    require "uri"
    p :bug_catcher
    res = SystemUtils.execute_command('hostname')
    hostname = res[:stdout]
    error_log_hash = {}
    error_log_hash[:message] = e.to_s
    e_str = e.to_s
    e.backtrace.each do |bt|
      e_str += bt + " \n"
    end
    error_log_hash[:backtrace] = e_str
    # error_log_hash[:request_params] = hostname
    error_log_hash[:return_url] = 'system'
    error_log_hash[:user_comment] = ''
    error_log_hash[:user_email] = 'backend@engines.onl'
    uri = URI.parse("http://buglog.engines.onl/api/v0/contact/bug_reports")
    response = Net::HTTP.post_form(uri, error_log_hash)
    return true
  rescue
    return false
  end

  def SystemUtils.last_error
    return @@last_error
  end

  def SystemUtils.level
    return @@level
  end

  def SystemUtils.debug
    return @@debug
  end

  #Execute @param cmd [String]
  #if sucessful exit code == 0 @return
  #else
  #@return stdout and stderr from cmd
  def SystemUtils.run_system(cmd)
    @@last_error = ''
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemUtils.debug_output('Run ' + cmd + ' ResultCode:' + $?.to_s + ' Output:', res)
      return true if $?.to_i == 0
      SystemUtils.log_error_mesg('Error Code:' + $?.to_s + ' in run ' + cmd + ' Output:', res)
      return res
    rescue Exception=>e
      SystemUtils.log_exception(e)
      SystemUtils.log_error_mesg('Exception Error in SystemUtils.run_system(cmd): ',cmd)
      return 'Exception Error in SystemUtils.run_system(cmd): ' +e.to_s
    end
  end

  def SystemUtils.hash_string_to_hash(hash_string)
    retval = {}
    hash_pairs = hash_string.split(':')
    hash_pairs.each do |hash_pair|
      pair = hash_pair.split('=')
      if pair.length > 1
        val = pair[1]
      else
        val = nil
      end
      retval[pair[0].to_sym] = val if pair.nil? == false && pair[0].nil? == false
    end
    return retval
  rescue Exception=>e
    SystemUtils.log_exception(e)
  end

  #Execute @param cmd [String]
  #@return hash
  #:result_code = command exit/result code
  #:stdout = what was written to standard out
  #:stderr = what was written to standard err
  def SystemUtils.execute_command(cmd)
    @@last_error = ''
    require 'open3'
    SystemUtils.debug_output('exec command ', cmd)
    p cmd
    retval = {}

    retval[:stdout] = ''
    retval[:stderr] = ''
    retval[:result] = -1

    Open3.popen3(cmd)  do |_stdin, stdout, stderr, th|
      oline = ''
      stderr_is_open = true
      begin
        stdout.each do |line|
          line = line.gsub(/\\\'/,'')  # remove rubys \' arround strings
          oline = line
          line.gsub!(/\/r/,'')
          retval[:stdout] += line
          retval[:stderr] += stderr.read_nonblock(256) if stderr_is_open
        end
        retval[:result] = th.value.exitstatus
      rescue Errno::EIO
        retval[:stdout] += oline.chop
        retval[:stdout] += stdout.read_nonblock(256)
        SystemUtils.debug_output('read stderr', oline)
        retval[:stderr] += stderr.read_nonblock(256)
      rescue IO::WaitReadable
        retry
      rescue EOFError
        if stdout.closed? == false
          stderr_is_open = false
          retry
        elsif stderr.closed? == false
          retval[:stderr] += stderr.read_nonblock(1000)
        end
      end
      return retval
    end
    return retval
  rescue Exception=>e
    SystemUtils.log_exception(e)
    SystemUtils.log_error_mesg('Exception Error in SystemUtils.execute_command(+ ' + cmd +'): ', retval)
    retval[:stderr] += 'Exception Error in SystemUtils.run_system(' + cmd + '): ' + e.to_s
    retval[:result] = -99
    return retval
  end

  #Execute @param cmd [String]
  #@return stdout and stderr from cmd
  #No indication of success
  def SystemUtils.run_command(cmd)
    @@last_error = ''
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemUtils.debug_output('Run ' + cmd + ' ResultCode:' + $?.to_s + ' Output:', res)
      return res
    rescue Exception=>e
      SystemUtils.log_exception(e)
      SystemUtils.log_error_mesg('Exception Error in SystemUtils.run_system(cmd): ', cmd)
      return 'Exception Error in SystemUtils.run_system(cmd): ' +e.to_s
    end
  end


  def SystemUtils.get_os_release_data
    os_data_hash = {}
    os_file = '/opt/engines/etc/os-release-host'
    os_file = '/etc/os-release' unless File.exist?(os_file)
    os_data = File.open(os_file).each do |line|
      line.strip!
      pair = line.split('=')
      os_data_hash[pair[0]] = pair[1].gsub(/\"/,"")
    end
    version_str = '15.1'
    version_str = os_data_hash['VERSION_ID'].gsub(/\"/,"") unless  os_data_hash['VERSION_ID'].nil?
    vers = version_str.split('.')
    os_data_hash['Major Version'] =  vers[0]
    os_data_hash['Minor Version'] = vers[1]
    os_data_hash['Patch Version'] = vers[2] if vers.count > 2
    # FIXME catch sub numbers as in 14.04.1
    return os_data_hash
  end

  def SystemUtils.cgroup_mem_dir(container_id_str)
    return '/sys/fs/cgroup/memory/docker/' + container_id_str + '/' if SystemUtils.get_os_release_data['Major Version'] == '14'
    return '/sys/fs/cgroup/memory/docker/' + container_id_str + '/'
    # old pre docker 1.9. return '/sys/fs/cgroup/memory/system.slice/docker-' + container_id_str + '.scope'
  end

  def SystemUtils.service_hash_variables_as_str(service_hash)
    argument = String.new
    if service_hash.key?(:publisher_namespace)
      argument = 'publisher_namespace=' + service_hash[:publisher_namespace] + ':type_path=' + service_hash[:type_path] + ':'
    end
    service_variables = service_hash[:variables]
    sources = ''
    return argument if service_variables.nil?
    service_variables.each_pair do |key,value|
      if key == :sources
        sources = value
        next
      end
      argument+= key.to_s + '=\'' + value.to_s + '\':'
    end
    argument += ' ' + sources
    return argument
  end
end
