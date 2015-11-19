module ReturnObjects
  # private ?
   # protected if protected static cant call
   def success(item_name, cmd)
     EnginesOSapiResult.success(item_name, cmd)
   end
 
   def failed(item_name, mesg, cmd)
     p :engines_os_api_fail_on
     p item_name
     p cmd
     p mesg.to_s + ':' + last_api_error.to_s
     EnginesOSapiResult.failed(item_name, mesg, cmd)
   end
 
   def self.failed(item_name, mesg, cmd)
     p :engines_os_api_fail_on_static
     p item_name
     p mesg + ':'
     p cmd
     EnginesOSapiResult.failed(item_name, mesg, cmd)
   end
   
  def log_exception_and_fail(cmd, e)
    e_str = SystemUtils.log_exception(e)
    failed('Exception', e_str, cmd)
  end

  def self.log_exception_and_fail(cmd, e)
    e_str = SystemUtils.log_exception(e)
    failed('Exception', e_str, cmd)
  end
  
end