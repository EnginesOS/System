class SystemUtils
  @@debug=true
  @@level=5
  
  attr_reader :debug,:level
  
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
        e_str += bt
      end
      @last_error = e_str
      SystemUtils.log_output(e_str,10)
    end
  
  def SystemUtils.level
      return @@level
    end
  def SystemUtils.debug
       return @@debug
     end
end