if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

def command_useage
 p "Inccorect usage"
 exit
end

def perform_get  
  rest_get(@route)  
end

def perform_post(params) 
  rest_post(@route,params)  
end

require 'rest-client'
def rest_get(path,params=nil)

  begin
    retry_count = 0
   # STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.get(@base_url + path, params)
      p r
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end

def rest_post(path,params)

  begin
    #STDERR.puts('Post Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.post(@base_url + path, params)
    p r
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
  end
end

@base_url = 'http://127.0.0.1:4567'
@route="/v0"
require_relative 'commands/commands.rb'

#require_relative 'rset.rb'




