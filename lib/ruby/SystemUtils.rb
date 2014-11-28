module SystemUtils
  @@debug=true
  @@level=5
  
 def SystemUtils.debug_output object
  if @debug == true  
    p object
  end  
 end
  
 def SystemUtils.debug_output(object,level)
  if @level < level  
    p object
  end 
 end
  
end