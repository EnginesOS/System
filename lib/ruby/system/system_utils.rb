class SystemUtils

  @@level=0
  def SystemUtils.last_error
    return @@last_error
  end

  def SystemUtils.log_level
    return @@level
  end
  def SystemUtils.level
     return @@level
   end
  require_relative 'system_debug.rb'

  require_relative 'system_utils/system_logging.rb'
  include SystemLogging
  require_relative 'system_utils/system_exceptions.rb'
  include SystemExceptions
  

  
 

  def SystemUtils.system_release
    return 'current' if File.exists?(SystemConfig.ReleaseFile) == false
    return File.read(SystemConfig.ReleaseFile).strip!

  end

  def SystemUtils.version
    return SystemUtils.system_release + '-' + SystemConfig.api_version.to_s + '-' + SystemConfig.engines_system_version.to_s
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


  #Execute @param cmd [String]
  #if sucessful exit code == 0 @return
  #else
  # @return stdout and stderr from cmd
  def SystemUtils.run_system(cmd)
    @@last_error = ''
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemDebug.debug(SystemDebug.execute,'Run ' + cmd + ' ResultCode:' + $?.to_s + ' Output:', res)
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
  # @return hash
  #:result_code = command exit/result code
  #:stdout = what was written to standard out
  #:stderr = what was written to standard err
  def SystemUtils.execute_command(cmd, binary=false, data = false, out=nil)
    @@last_error = ''
    require 'open3'
    SystemDebug.debug(SystemDebug.execute,'exec command ', cmd)
   
    retval = {}

    retval[:stdout] = ''
    retval[:stderr] = ''
    retval[:result] = -1
    retval[:command] = cmd

    Open3.popen3(cmd)  do |_stdin, stdout, stderr, th|
      
      _stdin.write(data) unless data.is_a?(FalseClass)       
      _stdin.close
      oline = ''
      stderr_is_open = true
      begin
     
        stdout.each do |line|
          unless binary
            line = line.gsub(/\\\'/,'')  # remove rubys \' arround strings
            oline = line
            line.gsub!(/\/r/,'')
          end
          if out.nil?
                 retval[:stdout] += line
                 else                   
                   out << line
               end
          retval[:stderr] += stderr.read_nonblock(256) if stderr_is_open
        end
        retval[:result] = th.value.exitstatus
      rescue Errno::EIO
        if out.nil?
               retval[:stdout] += line
               else 
                 out << line
             end
        retval[:stdout] += stdout.read_nonblock(256)
        SystemDebug.debug(SystemDebug.execute,'read stderr', oline)
        retval[:stderr] += stderr.read_nonblock(256)
      rescue IO::WaitReadable
        retry #unless th.status == false
       # retval[:result] = th.value.exitstatus
        #return retval
      rescue EOFError
        if stdout.closed? == false
          stderr_is_open = false
          retry unless th.status == false
          retval[:result] = th.value.exitstatus
          return retval
        elsif stderr.closed? == false
          retval[:stderr] += stderr.read_nonblock(1000)
          retval[:result] = th.value.exitstatus
           return retval 
        end
      end
     # File.delete('/tmp/import') if File.exist?('/tmp/import')
 
      return retval
    end
   # File.delete('/tmp/import') if File.exist?('/tmp/import')

    return retval
  rescue Exception=>e
  #  File.delete('/tmp/import') if File.exist?('/tmp/import')
    SystemUtils.log_exception(e)
    SystemUtils.log_error_mesg('Exception Error in SystemUtils.execute_command(+ ' + cmd +'): ', retval)
    retval[:stderr] += 'Exception Error in SystemUtils.run_system(' + cmd + '): ' + e.to_s
    retval[:result] = -99
    return retval
  end

  #Execute @param cmd [String]
  # @return stdout and stderr from cmd
  #No indication of success
  def SystemUtils.run_command(cmd)
    @@last_error = ''
    begin
      cmd = cmd + ' 2>&1'
      res= %x<#{cmd}>
      SystemDebug.debug(SystemDebug.execute,'Run ' + cmd + ' ResultCode:' + $?.to_s + ' Output:', res)
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
    os_data_file = File.open(os_file).each do |line|
      line.strip!
      pair = line.split('=')
      os_data_hash[pair[0]] = pair[1].gsub(/\"/,"")
    end
    version_str = '15.1'
    version_str = os_data_hash['VERSION_ID'].gsub(/\"/,"") unless  os_data_hash['VERSION_ID'].nil?
    vers = version_str.split('.')
    os_data_hash['Major Version'] = vers[0]
    os_data_hash['Minor Version'] = vers[1]
    os_data_hash['Patch Version'] = vers[2] if vers.count > 2
    os_data_file.close
    # FIXME catch sub numbers as in 14.04.1
    return os_data_hash
  end

  def SystemUtils.cgroup_mem_dir(container_id_str)
    return '/sys/fs/cgroup/memory/docker/' + container_id_str + '/' if SystemUtils.get_os_release_data['Major Version'] == '14'
    return '/sys/fs/cgroup/memory/docker/' + container_id_str + '/' if Dir.exist?('/sys/fs/cgroup/memory/docker/' + container_id_str + '/')
    return '/sys/fs/cgroup/memory/system.slice/docker-' + container_id_str + '.scope'
    # old pre docker 1.9. return '/sys/fs/cgroup/memory/system.slice/docker-' + container_id_str + '.scope'
  end
#def  SystemUtils.deal_with_json(res)
#   return self.symbolize_keys(res) if res.is_a?(Hash)
#   return self.symbolize_keys_array_members(res) if res.is_a?(Array)
#   return self.symbolize_tree(res) if res.is_a?(Tree::TreeNode)
#   return self.boolean_if_true_false_str(res) if res.is_a?(String)
#   return res
# rescue  StandardError => e
#   STDERR.puts('SystemUtils.deal_with_json ' + e.to_s) 
# end
#def SystemUtils.symbolize_keys_array_members(array)
#  return array if array.count == 0
#  return array unless array[0].is_a?(Hash)
#  retval = []
#  i = 0
#  array.each do |hash|
#    retval[i] = array[i]
#    next if hash.nil?
#    next unless hash.is_a?(Hash)
#    retval[i] = symbolize_keys(hash)
#    i += 1
#  end
#  return retval
#
#rescue  StandardError => e
#  log_exception(e)
#end
# 
# # Use when json is on cmdline '' to avoid confusion as in exec_create script.sh arg.json
# # so appears as exec_create script.sh 'arg.json' and does not throw parse errors 
#  def SystemUtils.hash_variables_as_json_str(service_hash_variables)
#    json_str = service_hash_variables.to_json
#    return  json_str
#
#  end
end
