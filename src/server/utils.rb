class Utils
  require_relative 'utils/service_hash.rb'
  require_relative 'utils/params.rb'
  def self.symbolize_keys(hash)
   # hash.delete('splat')
   # hash.delete('captures')
    
    return nil  if hash.nil?
    hash.inject({}){|result, (key, value)|
      new_key = case key
      when String then key.to_sym
      else key
      end
      new_value = case value
      when Hash then self.symbolize_keys(value)
      when Array then
        newval = []
       # STDERR.puts('symb in array ')
        value.each do |array_val|
          array_val = self.symbolize_keys(array_val) if array_val.is_a?(Hash)
          newval.push(array_val)
        #  STDERR.puts('new_val ;' + array_val.to_s)
          
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
     r
  rescue  StandardError => e
    STDERR.puts e.to_s
  end
  
  
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
#  def self.service_hash_from_params(params)
#splats = params['splat']
#  type_path = File.dirname(splats[0])       
#   service_handle = File.basename(splats[0])  
#        hash = {}
#        hash[:publisher_namespace] = params['ns']       
#        hash[:type_path] = type_path
#        hash[:service_handle] = service_handle
#        hash  
#end
#
#def self.engine_service_hash_from_params(params)
#  hash = self.service_hash_from_params(params)
#  hash[:parent_engine] = params['engine_name']
#  hash[:container_type] = 'container'
#  hash
#end
#
#def self.service_service_hash_from_params(params)
#    hash = self.service_hash_from_params(params)
#    hash[:parent_engine] = params['service_name'] 
#    hash[:container_type] = 'service'
#     return hash  
#end

#end

