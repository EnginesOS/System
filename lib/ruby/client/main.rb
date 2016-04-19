if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

def command_useage(mesg=nil)
 p "Inccorect usage"
 p mesg
 exit
end


def parse_rest_response(r)
  return false if r.code > 399
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  return r.to_s if @raw 
  res = JSON.parse(r, :create_additions => true)
  # STDERR.puts("RESPONSE "  + deal_with_jason(res).to_s)
  return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.to_s
  STDERR.puts e.backtrace
  STDERR.puts "Failed to parse rest response _" + r.to_s + "_"
  return false
end

def deal_with_jason(res)
  return symbolize_keys(res) if res.is_a?(Hash)
  return symbolize_keys_array_members(res) if res.is_a?(Array)
  return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
  return boolean_if_true_false_str(res) if res.is_a?(String)
  return res
rescue  StandardError => e
  STDERR.puts e.to_s
end

def boolean_if_true_false_str(r)
  if  r == 'true'
    return true
  elsif r == 'false'
    return false
  end
  return r
rescue  StandardError => e
  STDERR.puts e.to_s
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
rescue  StandardError => e
  STDERR.puts e.to_s
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

rescue  StandardError => e
  STDERR.puts e.to_s
end

def symbolize_tree(tree)
  nodes = tree.children
  nodes.each do |node|
    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
    symbolize_tree(node)
  end
  return tree
rescue  StandardError => e
  STDERR.puts e.to_s
end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  STDERR.puts e.to_s
end


 def read_stdin_data
   stdin_data = ""
   
   require 'timeout'
   status = Timeout::timeout(10) do
  while STDIN.gets
    stdin_data += $_
  end
   end
   stdin_data
 rescue Timeout::Error
   puts "Timeout on data read from stdin"  
 rescue StandardError => e
   log_exception(e)
 end
 
def perform_get  
  p @route
  rest_get(@route) 
  exit
end

def perform_post(params=nil) 
    
  p @route
  rest_post(@route,params)  
  exit
end
def perform_delete(params=nil) 
  p @route
  rest_delete(@route,params)  
  exit
end
require 'rest-client'
def rest_get(path,params=nil)

  begin
    retry_count = 0
   # STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.get(@base_url + path, params)
    p r.headers[:content_type]
     if @raw
       puts r.b 
     else
       p r
     end

  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end

def rest_post(path, params=nil)

  begin
    #STDERR.puts('Post Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.post(@base_url + path, params)
    p r
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end
def rest_delete(path, params=nil)

  begin
    #STDERR.puts('Post Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.delete(@base_url + path, params)
    p r
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end
@raw = false
@base_url = 'http://mgmt.engines.internal:4567'
@route="/v0"
require_relative 'commands/commands.rb'

#require_relative 'rset.rb'




