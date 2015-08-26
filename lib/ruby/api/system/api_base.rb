class ApiBase
  
  attr_reader :last_error
  
  def log_error_mesg(msg,object)
      obj_str = object.to_s.slice(0, 256)
      @last_error = @last_error.to_s + ':' + msg +':' + obj_str
      SystemUtils.log_error_mesg(msg, object)
    return false
    end
  
    def log_exception(e)
      @last_error = @last_error.to_s + e.to_s
      p @last_error + e.backtrace.to_s
      return false
    end
    
  def clear_error
       @last_error = ''
     end
     
     
  def log_exception(e)
    @last_error = e.to_s + e.backtrace.to_s
    SystemUtils.log_exception(e)
  end


end