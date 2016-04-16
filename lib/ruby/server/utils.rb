class RegistryUtils
  
  def RegistryUtils.boolean_if_true_false_str(r)
    return true if r == 'true'
    return false if r == 'false'
    return r
  end

def RegistryUtils.symbolize_keys(hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
    when String then key.to_sym
    else key
    end
    new_value = case value
    when Hash then RegistryUtils.symbolize_keys(value)
    when Array then
      newval = []
      value.each do |array_val|
        array_val = RegistryUtils.symbolize_keys(array_val) if array_val.is_a?(Hash)
        newval.push(array_val)
      end
      newval
    when String then
      RegistryUtils.boolean_if_true_false_str(value)
    else value
    end
    result[new_key] = new_value
    result
  }
end
def RegistryUtils.log_exception(e)
   e_str = e.to_s()
   e.backtrace.each do |bt|
     e_str += bt + ' \n'
   end
   @@last_error = e_str
   SystemUtils.log_output(e_str, 10)
   f = File.open('/opt/engines/run/service_manager/exceptions.' + Process.pid.to_s, 'a+')
   f.puts(e_str)
   f.close
  return false
 end

end
