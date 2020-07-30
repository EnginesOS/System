require 'json'
require 'ansi/code'


def check_length(check, len)
  must_have_data
  @data.strip!

  case check
  when 'eq'
    return true if @data.length == len
  when 'gt'
    return true if @data.length > len
  end
  STDERR.puts('got lenght of ' + @data.length.to_s + ' but expected ' + check + ' ' + len.to_s )
  false
end

def check_regex(exp)
  must_have_data
  return true unless @data.match(exp).nil?
  false
end

def check_text(key, value)
  must_have_data
  if key == nil || key == 'is'
    return true if @data == value
  else
    return true if @data.include?(value)
  end
  false
end

def check_boolean(value)
  return true if value.nil?
  if value.nil?
    return true if @data.to_s == 'false' || @data.to_s == 'true'
  else
    return true if @data.to_s == value
  end
end

def must_have_data
  exit -1 if @data.nil?
end

def check_array(key, value)
  must_have_data
  hash = JSON.parse(@data)
  unless value.nil?
    return false unless hash.is_a?(Array)
    return true if hash.include?(value)
    return false
  end
  return true if hash.is_a?(Array)
  false
rescue
  STDERR.puts("json problem with " +@data.to_s)
  false
end

def hash_has_key(search_key, hash)
  if search_key.include?(',')
    keys = search_key.split(',')
    keys.each do |key |
      return false unless hash.is_a?(Hash)
      return false unless hash.key?(key)
      hash = hash[key]
    end
    return true
  end
  return true if hash.key?(search_key)
  false
end

def hash_key_value(search_key, hash)
  if search_key.include?(',')
    keys = search_key.split(',')
    keys.each do |key |
      return false unless hash.is_a?(Hash)
      return false unless hash.key?(key)
      hash = hash[key]
    end
    return hash
  end
  return false unless hash.key?(search_key)
  hash[search_key].to_s
end

def check_json(key, value)
  must_have_data
  hash = JSON.parse(@data)
  if key.nil?
    key = value
    value = nil
  end
  return true if key.nil?
  if value.nil?
    return true if hash_has_key(key, hash)
  else
    return true if hash_key_value(key, hash) == value
  end
  false
rescue StandardError =>e
  STDERR.puts('Json Parse Error ' + e.to_s + "\n With " + @data.to_s)
  false
end

def read_stdin_data
  stdin_data = ""
  require 'timeout'
  status = Timeout::timeout(480) do
    while STDIN.gets
      stdin_data += $_
    end
    # stdin_data = STDIN.read
  end
  #   puts "Read " + stdin_data.length.to_s + ' bytes ' + stdin_data
  return nil if stdin_data.nil?
  stdin_data.strip!
  stdin_data
rescue Timeout::Error
  STDERR.puts "Timeout on data read from stdin"
rescue StandardError => e
  log_exception(e)
end

def log_exception(e)
  STDERR.puts("Exception " + e.to_s + "\n" + e.backtrace.to_s)
end

key = nil
value = nil

if ARGV[0] == 'not'
  @invert = true
  ARGV.delete_at(0)
else
  @invert = false
end

type = ARGV[0]

if ARGV.count == 2
  value = ARGV[1]
elsif ARGV.count > 2
  value = ARGV[2]
  key = ARGV[1]
end

@data = read_stdin_data
#exit -1 if @data.nil?

if @data.include?("Incorrect usage")
  p 'Error with Test entry ' + @data.to_s
  exit -1
end
r = false

case type
when 'json'
  r = check_json(key, value)
when 'bool'
  r = check_boolean(value)
when 'text'
  r = check_text(key, value)
when 'text_len'
  value =  value.to_i
  r = check_length(key, value)
when 'regex'
  r = check_regex(value)
when 'array'
  r = check_array(key, value)
else
  puts ANSI.orange{'Unrecognised expect type:' + type.to_s}
  exit(-1)
end
r = !r if @invert
if r == false
  if type.nil?
    puts ANSI.red{'Got ' + @data.to_s + " but expected:" + type.to_s }
  else
    puts ANSI.red{'Failed:Got ' + @data.to_s + " but expected:" + value.to_s}
  end
  exit -1
else
  puts ANSI.green{'OK'}
  end