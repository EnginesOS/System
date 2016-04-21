class Utils
  def self.symbolize_keys(hash)
   # hash.delete('splat')
   # hash.delete('captures')
    
    return log_error('cannot symbolse nil ')  if hash.nil?
    hash.inject({}){|result, (key, value)|
      new_key = case key
      when String then key.to_sym
      else key
      end
      new_value = case value
      when Hash then self.symbolize_keys(value)
      when Array then
        newval = []
        value.each do |array_val|
          array_val = self.symbolize_keys(array_val) if array_val.is_a?(Hash)
          newval.push(array_val)
        end
        newval
      when String then
        self.boolean_if_true_false_str(value)
      else value
      end
      result[new_key] = new_value
      result
    }
  end

  def self.boolean_if_true_false_str(r)
    if  r == 'true'
      return true
    elsif r == 'false'
      return false
    end
    return r
  rescue  StandardError => e
    STDERR.puts e.to_s
  end
  #def log_exception(e)
  #   e_str = e.to_s()
  #   e.backtrace.each do |bt|
  #     e_str += bt + ' \n'
  #   end
  #   @@last_error = e_str
  #   SystemUtils.log_output(e_str, 10)
  #   f = File.open('/opt/engines/run/service_manager/exceptions.' + Process.pid.to_s, 'a+')
  #   f.puts(e_str)
  #   f.close
  #  return false
  # end
  def self.service_hash_from_params(params)
splats = params['splat']
  type_path = File.dirname(splats[0])       
   service_handle = File.basename(splats[0])  
        hash = {}
        hash[:publisher_namespace] = params['ns']
        hash[:parent_engine] = params['engine_name']
        hash[:parent_engine] = params['service_name'] if  hash[:parent_engine].nil?
  # return missing_params engine_name|service_name if  hash[:parent_engine].nil?
        hash[:type_path] = type_path
        hash[:container_type] = 'container'
        hash[:service_handle] = service_handle
        hash  
end
def self.service_service_hash_from_params(params)
    hash = self.service_hash_from_params(params)
    hash[:container_type] = 'service'
     return hash  
end
end

