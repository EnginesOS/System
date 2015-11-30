class DockerConnection
  #require 'rest-client'
  require 'streamly'
  def initialize
    
  end
  
  def request_stream(address,params,handler)
    Streamly.post address , params do |body_chunk|
      handler.received_chuck(body_chunk)
      # do something with body_chunk
    end
    
  end
  
  private
  
  def parse_rest_response(r)
    return false if r.code > 399
    return true if r.to_s   == '' ||  r.to_s   == 'true'
    return false if r.to_s  == 'false'
    res = JSON.parse(r, :create_additions => true)
    # STDERR.puts("RESPONSE "  + deal_with_jason(res).to_s)
    return res
  rescue  StandardError => e
    STDERR.puts e.to_s
    STDERR.puts "Failed to parse rest response _" + res.to_s + "_"
    return false
  end
  
end