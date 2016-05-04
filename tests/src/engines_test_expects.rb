

def check_text(key, value)
   if key == nil || key == 'is'
     return true if @data = value    
   else
     return true if @data.include?(value)     
   end  
   return false
end

def check_boolean(value)
  if value.nil?
    return true if @data == 'false' || @data == 'true'
  else
    return true if @data == value
  end  
 
  return false
end
def check_array(key, value)
  hash = JSON.parse(@data)
  return true if hash.is_a?(Array)
  return false
  rescue
    return false
end
  
def check_json(key, value)
  hash = JSON.parse(@data)
  return true if key.nil?
  if value.nil?
    return true if hash.key?(key)
  else
    return true if hash[key] == value
  end
return false
rescue
  return false
end


def read_stdin_data
  stdin_data = ""
  
  require 'timeout'
  status = Timeout::timeout(10) do
 while STDIN.gets
   stdin_data += $_
 end
  end
 # puts "Read " + stdin_data.length.to_s + ' bytes ' + stdin_data
  stdin_data
rescue Timeout::Error
  puts "Timeout on data read from stdin"  
rescue StandardError => e
  log_exception(e)
end


key=nil
value=nil
type=ARGV[0]

if ARGV.count == 2
  value=ARGV[1]
elsif ARGV.count > 2
value = ARGV[2]
key = ARGV[1]
end

@data=read_stdin_data
@data.strip!
if @data.include?("Incorrect usage")
  p 'Test Error ' + @data.to_s
 exit -1
end

case type
when 'json'
 r = check_json(key, value)
  
when 'bool'
  r = check_boolean(value)
  
when 'text'
  r = check_text(key, value)

  
when 'array'
  r = check_array(key, value)
  
end


if r == false

puts 'Failed:Got ' + @data.to_s + " but expected:" + value
  exit -1
else
  puts 'OK'
end