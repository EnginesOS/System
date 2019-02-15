def deal_with_json(res)
  unless res.nil?
    res = parse_as_json(res) unless res.is_a?(Hash)
    symbolise_json(res)
  end
rescue StandardError => e
  #log_error_mesg(' parse problem with ' + res.to_s)
  STDERR.puts('Exception: '+ e.to_s + "\n" + e.backtrace.to_s )
  res
end

def parse_as_json(res)
  JSON.parse(res, create_additions: true)
end

def symbolise_json(res)
  STDERR.puts("Symbolising " + hash.class.name)
  if res.is_a?(Hash)
    symbolize_keys(res)
  elsif res.is_a?(Array)
    symbolize_keys_array_members(res)
  elsif res.is_a?(Tree::TreeNode)
    symbolize_tree(res)
  elsif res.is_a?(String)
    boolean_if_true_false_str(res)
  else
    res
  end
end

def symbolize_keys_array_members(array)
  unless array.count == 0
    if array[0].is_a?(Hash)
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
    else
      array
    end
  else
    array
  end
end

def symbolize_keys(hash)
   return hash unless hash.is_a?(Hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
    when String then key.to_sym
    else key
    end
#    STDERR.puts('key ' + new_key.to_s + ':' +new_key.class.name)
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
    true
  elsif r == 'false'
    false
  else
    r
  end
end

def symbolize_tree(tree)
  STDERR.puts("Symbolising " + tree.class.name)
  nodes = tree.children
  nodes.each do |node|
    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
    symbolize_tree(node)
  end
  tree

end