if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

def perform_get
  
  rest_get(@route)
  
end
def rest_get(path,params=nil)
  require 'rest-client'
  begin
    retry_count = 0
   # STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.get(@base_url + path, params)
      p r
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end


@base_url = 'http://127.0.0.1:4567'
@route="/v0"
require_relative 'commands/commands.rb'

#require_relative 'rset.rb'




