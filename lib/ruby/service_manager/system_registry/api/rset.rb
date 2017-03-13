require 'rest-client'

require '/opt/engines/lib/ruby/api/system/deal_with_json.rb'
def json_parser    
     @json_parser = Yajl::Parser.new(:create_additions => true,:symbolize_keys => true) if @json_parser.nil?
     @json_parser
   end
def rest_get(path,params = nil)
  return base_url if base_url.is_a?(EnginesError)
  begin
    retry_count = 0
   #STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s + ' base_url ' + base_url.to_s)
    
    parse_rest_response(RestClient.get(base_url + path, params))
   rescue RestClient::ExceptionWithResponse => e   
     parse_error(e.response)
  rescue StandardError => e       
    log_exception(e, params)

  end
end

def rest_post(path,params = nil)
  begin
    parse_rest_response(RestClient.post(base_url + path, params))
    rescue RestClient::ExceptionWithResponse => e   
      parse_error(e.response)
  rescue StandardError => e
    log_exception(e, params)
  end
end

def rest_put(path,param = nils)
  begin
    parse_rest_response(RestClient.put(base_url + path, params))
    rescue RestClient::ExceptionWithResponse => e      
      parse_error(e.response)
  rescue StandardError => e
    log_exception(e, params)
  end
end

def rest_delete(path,params = nil)
  begin
    parse_rest_response(RestClient.delete(base_url + path, params))
    rescue RestClient::ExceptionWithResponse => e   
      parse_error(e.response)
  rescue StandardError => e
    log_exception(e, params)
  end
end

private

def parse_error(r)
  r.strip!
  res = JSON.parse(r, :create_additions => true)
  EnginesRegistryError.new(deal_with_jason(res))
  rescue  StandardError => e
  STDERR.puts(r.to_s)
  STDERR.puts(e.to_s)
  return log_error_mesg("Parse Error on error response object ", r.to_s)
  
end


def parse_rest_response(r)
  return parse_error(r) if r.code > 399
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  r.strip!
  res = JSON.parse(r, :create_additions => true)
  # STDERR.puts("RESPONSE "  + deal_with_jason(res).to_s)
  return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.to_s
  STDERR.puts e.backtrace
  STDERR.puts "Failed to parse Registry response _" + r.to_s + "_"
  return log_exception(e, r)
end

#def deal_with_jason(res)
#  return symbolize_keys(res) if res.is_a?(Hash)
#  return symbolize_keys_array_members(res) if res.is_a?(Array)
#  return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
#  return boolean_if_true_false_str(res) if res.is_a?(String)
#  return res
#rescue  StandardError => e
#  log_exception(e, res)
#end

#def boolean_if_true_false_str(r)
#  if  r == 'true'
#    return true
#  elsif r == 'false'
#    return false
#  end
#  return r
#rescue  StandardError => e
#  log_exception(e, r)
#end
#
#def symbolize_keys(hash)
#  hash.inject({}){|result, (key, value)|
#    new_key = case key
#    when String then key.to_sym
#    else key
#    end
#    new_value = case value
#    when Hash then symbolize_keys(value)
#    when Array then
#      newval = []
#      value.each do |array_val|
#        array_val = symbolize_keys(array_val) if array_val.is_a?(Hash)
#        array_val =  boolean_if_true_false_str(array_val) if array_val.is_a?(String)
#        newval.push(array_val)
#      end
#      newval
#    when String then
#      boolean_if_true_false_str(value)
#    else value
#    end
#    result[new_key] = new_value
#    result
#  }
#rescue  StandardError => e
#log_exception(e, hash)
#end
#
#def symbolize_keys_array_members(array)
#  return array if array.count == 0
#  return array unless array[0].is_a?(Hash)
#  retval = []
#  i = 0
#  array.each do |hash|
#    retval[i] = array[i]
#    next if hash.nil?
#    next unless hash.is_a?(Hash)
#    retval[i] = symbolize_keys(hash)
#    i += 1
#  end
#  return retval
#
#rescue  StandardError => e
#log_exception(e)
#end
#
#def symbolize_tree(tree)
#  nodes = tree.children
#  nodes.each do |node|
#    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
#    symbolize_tree(node)
#  end
#  return tree
#rescue  StandardError => e
#  log_exception(e)
#end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  log_exception(e)
end
