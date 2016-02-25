module SystemLogging
  attr_reader :debug, :level, :last_error

  def SystemUtils.last_error
    return @@last_error
  end

  def SystemUtils.log_level
    return @@level
  end
  
  def SystemUtils.log_output(object, level)
     if SystemUtils.level < level
       STDERR.puts 'Error[' + Process.pid.to_s + ']:'+ object.to_s if level == 10
       puts 'Error ' + object.to_s
     end
     return false
   end
   
  def SystemUtils.debug_output(label, object = nil)
     STDERR.puts  label.to_s + ":" + object.to_s  if SystemUtils.debug == true
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

end