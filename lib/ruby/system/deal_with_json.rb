
def  deal_with_jason(res)  
  r = parse_as_json(res)
  symbolise_json(r)  
end

def parse_as_json(res)
  res = JSON.parse(res, create_additions: true)
end

def symbolise_json(res)
 return symbolize_keys(res) if res.is_a?(Hash)
 return symbolize_keys_array_members(res) if res.is_a?(Array)
 return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
 return boolean_if_true_false_str(res) if res.is_a?(String)
  res
rescue  StandardError => e
 STDERR.puts('SystemUtils.deal_with_jason ' + e.to_s) 
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
 retval

rescue StandardError => e
log_exception(e)
end

def symbolize_keys(hash)
   hash.inject({}){|result, (key, value)|
     new_key = case key
     when String then key.to_sym
     else key
     end
     new_value = case value
     when Hash then symbolize_keys(value)
     when Array   then
       newval = []
       value.each do |array_val|
         if array_val.is_a?(Hash)
           array_val = symbolize_keys(array_val)
         end
         newval.push(array_val)
       end
       newval
     else value
     end
     result[new_key] = new_value
     result
   }
 end
 
def boolean_if_true_false_str(r)
  if  r == 'true'
    return true
  elsif r == 'false'
    return false
  end
   r
rescue  StandardError => e
  log_exception(e, r)
end

def symbolize_tree(tree)
  nodes = tree.children
  nodes.each do |node|
    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
    symbolize_tree(node)
  end
   tree
rescue  StandardError => e
  log_exception(e)
end