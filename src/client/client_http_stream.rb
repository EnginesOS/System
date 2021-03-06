
module ClientHTTPStream
  require 'net/http'

  
def parse_complete(hash)
  p("#{Time.now}:#{hash.to_json}")
end
#used by events
def get_json_stream(path)
  require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  options = nil
options = { use_ssl: true, uri.scheme => 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE} if @use_https == true
  Net::HTTP.start(uri.host, uri.port, options)  do |http|
    req = Net::HTTP::Get.new(uri)
    req['access_token'] = ENV['access_token']
    req['HTTP_access_token'] = ENV['access_token']
    parser = Yajl::Parser.new({symbolize_keys: true})
  parser.on_parse_complete = method(:parse_complete)
    http.request(req) { |resp|
      #  resp.header.each_header {|key,value| STDERR.puts "#{key} = #{value}" }
      resp.read_body do |chunk|
        begin
       #   next if chunk == "\0" || chunk == "\n"
       #   chunk.gsub!(/}[ \n]$/, '}')   
          parser << chunk
          rescue Net::HTTPGatewayTimeout
          STDERR.puts("retry")
          get_json_stream(path)
        rescue StandardError => e
          p e
          #Can be because chunk is not the complete json
          STDERR.puts("#{resp} _BAD_CHUNK  #{chunk}")
          next
        end
      end
    }
    exit
  end
rescue StandardError => e
  #Should goto to error hanlder but this is a script
  p e.to_s
  p e.backtrace.to_s
end

## Used By builder command
def get_stream(path, ostream = STDOUT)
  #require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  req = Net::HTTP::Get.new(uri)
  req['Access_Token'] = ENV['access_token']
  options = {use_ssl: true, uri.scheme => 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE} if @use_https == true
  Net::HTTP.start(uri.host, uri.port, options) do |http|
    http.read_timeout = 600
   
    http.request(req) { |resp|
   #   STDERR.puts('header')
      resp.header.each_header {|key,value| STDERR.puts "#{key} = #{value}" }
      resp.read_body do |chunk|
        ostream.write(chunk)
      end
    }
    exit
  end
rescue StandardError => e
  p e.to_s
  p chunk.to_s
  p e.backtrace.to_s
end
end