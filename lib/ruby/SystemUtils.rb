class SystemUtils
  @@debug=true
  @@level=5
  
  attr_reader :debug,:level,:last_error
  
 def SystemUtils.debug_output object
  if SystemUtils.debug == true  
    p object
  end  
 end
  
 def SystemUtils.log_output(object,level)
  if SystemUtils.level < level
    p :Error  
    p object
  end 
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
     
  def SystemUtils.run_system(cmd)
    @@last_error=""
      begin
        cmd = cmd + " 2>&1"
        res= %x<#{cmd}>
        SystemUtils.debug_output res
        return res        
      rescue Exception=>e
        SystemUtils.log_exception(e)
        return e.to_s
      end
    end   
     
end