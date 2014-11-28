class SystemUtils
  @@debug=true
  @@level=5
  
  attr_reader :debug,:level
  
 def SystemUtils.debug_output object
  if SystemUtils.debug == true  
    p object
  end  
 end
  
 def SystemUtils.debug_output(object,level)
  if SystemUtils.level < level  
    p object
  end 
 end
  
end