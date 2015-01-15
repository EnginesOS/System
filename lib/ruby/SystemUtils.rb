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
      @@last_error = e_stre_str
      p 
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
      clear_error
      begin
        cmd = cmd + " 2>&1"
        res= %x<#{cmd}>
        SystemUtils.debug_output res
        #FIXME should be case insensitive The last one is a pure kludge
        #really need to get stderr and stdout separately
        if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
          return true
        else
          @last_error = res
          SystemUtils.debug_output res
          return false
        end
      rescue Exception=>e
        SystemUtils.log_exception(e)
        return ret_val
      end
    end   
     
end