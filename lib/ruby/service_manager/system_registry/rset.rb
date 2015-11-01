require 'rest-client'
  
  def rest_get(path,params)
    begin
      retry_count = 0
    STDERR.puts('Path:' + path.to_s + ' Params:' + params.to_s)
    parse_rest_response(RestClient.get(base_url + path, params))
    rescue StandardError => e
      STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
    end
  end
  
  def rest_post(path,params)
    begin
    parse_rest_response(RestClient.post(base_url + path, params))
    rescue StandardError => e
      STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
    end
  end
  
  def rest_put(path,params)
    begin
    parse_rest_response(RestClient.put(base_url + path, params))
    rescue StandardError => e
      STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
    end
  end
  
  def rest_delete(path,params)
    begin
    parse_rest_response(RestClient.delete(base_url + path, params))
    rescue StandardError => e
      STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
    end
  end
  
 private 
  
def parse_rest_response(r)
     return false if r.code > 399
   return true if r.to_s   == '' ||  r.to_s   == 'true'
   return false if r.to_s  == 'false' 
    res = JSON.parse(r, :create_additions => true)       
    STDERR.puts("res "  + deal_with_jason(res).to_s)  
    return deal_with_jason(res)
  rescue
    p "Failed to parse rest response _" + res.to_s + "_"
      return false
 end
 
 def deal_with_jason(res)
   return symbolize_keys(res) if res.is_a?(Hash)
   return symbolize_keys_array_members(res) if res.is_a?(Array)
   return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
   return boolean_if_true_false_str(res) if res.is_a?(String)
   return res
 end
 
 def boolean_if_true_false_str(r)
                  if  r == 'true'
                    return true
                  elsif r == 'false'
                   return false
                  end
       return r     
 end  
 
 def symbolize_keys(hash)
   hash.inject({}){|result, (key, value)|
     new_key = case key
     when String then key.to_sym
     else key
     end
     new_value = case value
     when Hash then symbolize_keys(value)
     when Array then
       newval = []
       value.each do |array_val|        
           array_val = symbolize_keys(array_val) if array_val.is_a?(Hash)
           array_val =  boolean_if_true_false_str(array_val) if array_val.is_a?(String)
         newval.push(array_val)
       end
       newval
       when String then
       boolean_if_true_false_str(value)
     else value
     end
     result[new_key] = new_value
     result
   }
 end
       
 def symbolize_keys_array_members(array)
    return array if array.count == 0
   return array unless array[0].is_a?(Hash)
   retval = []
   i = 0
   array.each do |hash|
     retval[i] = array[i]
     next if hash.nil?
     next unless hash.is_a?(Hash)       
     retval[i] = symbolize_keys(hash)
     i += 1
   end
 return retval
  end
  
  def symbolize_tree(tree)     
    nodes = tree.children
     nodes.each do |node|
       node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
       symbolize_tree(node)
     end
     return tree
  end
    
 def base_url
   'http://' + @core_api.get_registry_ip + ':4567'
 end
 
 