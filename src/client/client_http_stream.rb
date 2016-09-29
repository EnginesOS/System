
module ClientHTTPStream


#used by events
def get_json_stream(path)
  require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  Net::HTTP.start(uri.host, uri.port)  do |http|
    req = Net::HTTP::Get.new(uri)
    req['access_token'] = ENV['access_token']
    req['HTTP_access_token'] = ENV['access_token']
    parser = Yajl::Parser.new(:symbolize_keys => true)
    http.request(req) { |resp|
      resp.read_body do |chunk|
        begin
          next if chunk == "\0" || chunk == "\n"
          hash = parser.parse(chunk) do |hash|
            p hash.to_json
          end
          #dont panic on bad json as it is the \0 keep alive
        rescue StandardError => e
          p e
          STDERR.puts('_'+ chunk + '_')
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
def get_stream(path, ostream=STDOUT)
  #require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  req = Net::HTTP::Get.new(uri)
  req['Access_Token'] = ENV['access_token']

  Net::HTTP.start(uri.host, uri.port)  do |http|
    http.read_timeout = 600
    http.request(req) { |resp|
      resp.read_body do |chunk|
        #hash = parser.parse(chunk) do |hash|
        ostream.write(chunk)
        #end
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