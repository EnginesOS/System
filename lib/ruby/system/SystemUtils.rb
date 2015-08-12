class SystemUtils
  @@debug=true
  @@level=5

  attr_reader :debug,:level,:last_error
  def SystemUtils.debug_output(label,object)
    if SystemUtils.debug == true
      p label.to_sym
      p object
    end
  end

  def SystemUtils.log_output(object,level)
    if SystemUtils.level < level
      p :Error
      p object.to_s
    end
  end

  #@Logs to passeenger std out the @msg followed by @object.to_s
  #Logs are written to apache/error.log
  # error mesg is truncated to 512 bytes
  # returns nothing
  def SystemUtils.log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,512)
    SystemUtils.log_output(msg + ":->:" + obj_str ,10)
  end

  def SystemUtils.log_error(object)
    SystemUtils.log_output(object,10)
  end
  
  def SystemUtils.get_service_pubkey(service,cmd)
    cmd_line = "docker exec " + service + " /home/get_pubkey.sh " + cmd     
    key = SystemUtils.run_command(cmd_line)
    p key
    return key
  end
  
  def SystemUtils.system_release
    if File.exists?(SysConfig.ReleaseFile) == false
         return "current"
       end
       release =  File.read(SysConfig.ReleaseFile)
       return release.strip    
  end
  
  def SystemUtils.version
     return SystemUtils.system_release + "." + SysConfig.api_version + "." + SysConfig.engines_system_version
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
        newval=Array.new
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
    e_str = e.to_s()
    e.backtrace.each do |bt |
      e_str += bt + " \n"
    end
    @@last_error = e_str
    p e_str
    SystemUtils.log_output(e_str,10)
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
    @@last_error=""
    begin
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>
      SystemUtils.debug_output("Run " + cmd + " ResultCode:" + $?.to_s + " Output:", res)
      if $?.to_i == 0
        p :run_system_success
        return true
      else
        SystemUtils.log_error_mesg("Error Code:" + $?.to_s + " in run " + cmd + " Output:", res)
        return $res
      end
    rescue Exception=>e
      SystemUtils.log_exception(e)
      SystemUtils.log_error_mesg("Exception Error in SystemUtils.run_system(cmd): ")
      return "Exception Error in SystemUtils.run_system(cmd): " +e.to_s
    end
  end
  def SystemUtils.hash_string_to_hash(hash_string)
    retval = Hash.new
    
    hash_pairs = hash_string.split(":")
      hash_pairs.each do |hash_pair|
        pair = hash_pair.split("=")
        if pair.length > 1
          val = pair[1]
          else
          val = nil
        end
          
        if pair != nil && pair[0] != nil
          retval[pair[0].to_sym] = val
        end        
     end

    return retval
rescue Exception=>e
      SystemUtils.log_exception(e)
      
  end
#Execute @param cmd [String]
    #@return hash
    #:result_code = command exit/result code
    #:stdout = what was written to standard out
    #:stderr = wahat was written to standard err
def SystemUtils.execute_command(cmd)
     @@last_error=""
     
  require 'open3'
   SystemUtils.debug_output("exec command ",cmd)

   retval = Hash.new
   retval[:stdout] = String.new
   retval[:stderr] = String.new
   retval[:result] = -1

     Open3.popen3(cmd)  do |stdin, stdout, stderr, th|
       oline = String.new
       stderr_is_open=true
       begin
         stdout.each do |line|
           line = line.gsub(/\\\"/,"")
           oline = line
           retval[:stdout]+= line.chop
           #              p :lne_by_line
           #              p line
           if stderr_is_open
             retval[:stderr] += stderr.read_nonblock(256)
           end
         end
         
         retval[:result] = th.value.exitstatus 
         
       rescue Errno::EIO
         retval[:stdout] += oline.chop
         retval[:stdout] += stdin.read_nonblock(256) 
         SystemUtils.debug_output("read stderr",oline)
         retval[:stderr]  += stderr.read_nonblock(256)
       rescue  IO::WaitReadable
         retry
       rescue EOFError
         
         if stdout.closed? == false
           stderr_is_open = false
           retry
         elsif stderr.closed? == false
           retval[:stderr]  += stderr.read_nonblock(1000)
         end
         
       end
        
         return retval
 
       end       
  
     return retval

     rescue Exception=>e
       SystemUtils.log_exception(e)
       SystemUtils.log_error_mesg("Exception Error in SystemUtils.execute_command(+ " + cmd +"): ",retval)
       retval[:stderr] += "Exception Error in SystemUtils.run_system(" + cmd + "): " +e.to_s
       retval[:result] =-99
       return retval
   end
  
  
   #Execute @param cmd [String]
    #@return stdout and stderr from cmd
    #No indication of success
    def SystemUtils.run_command(cmd)
      @@last_error=""
      begin
        cmd = cmd + " 2>&1"
        res= %x<#{cmd}>
        SystemUtils.debug_output("Run " + cmd + " ResultCode:" + $?.to_s + " Output:", res)
       
        return res

      rescue Exception=>e
        SystemUtils.log_exception(e)
        SystemUtils.log_error_mesg("Exception Error in SystemUtils.run_system(cmd): ")
        return "Exception Error in SystemUtils.run_system(cmd): " +e.to_s
      end
    end

#  def SystemUtils.get_default_domain
#    if File.exists?(SysConfig.DefaultDomainnameFile)
#      domain = File.read(SysConfig.DefaultDomainnameFile)
#      return domain.strip
#    else
#      return "engines"
#    end
#  end

  #@return [Hash] completed dns service_hash for engine on the engines.internal dns for
  #@param engine [ManagedContainer]
  def SystemUtils.create_dns_service_hash(engine)
    service_hash = Hash.new

    service_hash[:publisher_namespace] = "EnginesSystem"
    service_hash[:type_path] = 'dns'
    service_hash[:persistance] = false
    service_hash[:service_container_name]='dns'  
    service_hash[:parent_engine]=engine.container_name
    service_hash[:container_type]=engine.ctype
    service_hash[:variables] = Hash.new
    service_hash[:variables][:parent_engine]= engine.container_name

    if engine.ctype == "service"
      service_hash[:variables][:hostname]=engine.hostname
    else
      service_hash[:variables][:hostname]=engine.container_name
    end
    service_hash[:variables][:name]=service_hash[:variables][:hostname]
    service_hash[:container_type]=engine.ctype
    service_hash[:variables][:ip]=engine.get_ip_str.to_s
    service_hash[:service_handle]=service_hash[:variables][:name]
    p :created_dns_service_hash
    p service_hash
    return service_hash
  end

  #@return [Hash] completed nginx service_hash for engine on for the default website configured for
  #@param engine [ManagedContainer]
  def SystemUtils.create_nginx_service_hash(engine)

    proto ="http_https"
    case engine.protocol
    when :https_only
      proto="https"
    when :http_and_https
      proto ="http_https"
    when :http_only
      proto="http"
    end
    #
    #    p :proto
    #    p proto

    service_hash = Hash.new()
    service_hash[:variables] = Hash.new
    service_hash[:persistance] = false
    service_hash[:service_container_name]='nginx'
    service_hash[:parent_engine]=engine.container_name
    service_hash[:variables][:parent_engine]=engine.container_name
    service_hash[:variables][:name]=engine.container_name
    service_hash[:service_handle] =  engine.fqdn
    service_hash[:container_type]=engine.ctype
    service_hash[:variables][:fqdn]=engine.fqdn
    service_hash[:variables][:port]=engine.port.to_s
    service_hash[:variables][:proto]= proto
    service_hash[:type_path] = 'nginx'
    service_hash[:publisher_namespace] = "EnginesSystem"
    SystemUtils.debug_output("create nginx Hash",service_hash)
    return service_hash

  end
  
  
def SystemUtils.service_hash_variables_as_str(service_hash)
   argument = String.new
   if service_hash.has_key?(:publisher_namespace) 
     argument = "publisher_namespace=" + service_hash[:publisher_namespace] +":type_path="+service_hash[:type_path]+":"
   end
   service_variables =  service_hash[:variables]
     sources = ""
     if service_variables == nil
       return argument
     end
   service_variables.each_pair do |key,value|
     if key == :sources
       sources = value
       next 
     end
          
     argument+= key.to_s + "=\"" + value.to_s + "\":"      
   end
   
  argument += " " + sources
   
   return argument
 end
 
end