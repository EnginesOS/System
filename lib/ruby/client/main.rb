if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

def command_useage
 p "Inccorect usage"
 exit
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

def perform_post(params) 
  p @route
  rest_post(@route,params)  
  exit
end

require 'rest-client'
def rest_get(path,params=nil)

  begin
    retry_count = 0
   # STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.get(@base_url + path, params)
      p r

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




