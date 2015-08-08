class NetworkSystemRegistry
require 'yaml'
#  require 'json'
 attr_accessor  :port,
                :retry_count_limit,
                :last_error
                
  def initialize(core_api)
    @retry_count_limit=5
  @core_api = core_api
  server_ip = server
  @port=SysConfig.RegistryPort
  @registry_socket = open_socket(server_ip,@port)    
    
    if @registry_socket.is_a?(String) == true
      p @registry_socket.to_s
      return nil
    end
 
    
  end

 def server
   @core_api.get_registry_ip
  # return "192.168.208.101"
 end 



  def symbolize_top_level_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
      when String then key.to_sym
      else key
      end
      result[new_key] = value
      result
    }
  end

  def wait_for_reply(socket)
    #  def process_messages(socket)
    begin

      first_bytes = socket.read_nonblock(32768)

      end_tag_indx = first_bytes.index(',')

      mesg_lng_str = first_bytes.slice(0,end_tag_indx)

      mesg_len =  mesg_lng_str.to_i
      p :mesg_len
      p mesg_len
      total_length = first_bytes.size
      end_byte =  total_length - end_tag_indx
      messege_response = first_bytes.slice(end_tag_indx+1,end_byte+1)

      while messege_response.size < mesg_len
        begin
          more = socket.read_nonblock(32768)
          messege_response = messege_response + more
        rescue IO::EAGAINWaitReadable
          p :retry_in_wait_for_reply
          retry
          
        end
      end
      
    rescue EOFError
      return nil
      
    rescue IO::EAGAINWaitReadable
      retry
        
  rescue Exception=>e
    p "Eception"
    p e.to_s
    p e.backtrace.to_s
    end

    response_hash = YAML::load(messege_response)
    p :response_as_yaml
    p response_hash
    if response_hash[:object] == nil
      return nil
    end
    return YAML::load(response_hash[:object])

  end

  def build_mesg(mesg_str)
    header = mesg_str.to_s.length
    return header.to_s + "," + mesg_str.to_s
  end

  
  def send_request(command,params)
    retry_count=0
  
    def send_request_failed(command,params)
        SystemUtils.log_error_mesg("Failed to send command " +command + " with:" + @last_error, params)
        return false
    end
    
     request_hash = Hash.new
     request_hash[:value]=params    
    request_hash[:command] = command
    request_yaml = request_hash.to_yaml
    mesg_str = build_mesg(request_yaml)
    
    begin
      #Check if open Will chuck an error if not and read nothing if is 
      if  @registry_socket.is_a?(String)
        p :REGSOCKER_OS_TRIOGN
        p @registry_socket
      end
      status = Timeout::timeout(5) {
    
     @registry_socket.read_nonblock(0)
    
      @registry_socket.send(mesg_str,0)
      }
      p :Sent
      p "Message:" + mesg_str.to_s
     
      
    rescue Errno::EIO
      retry_count+=1
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        p   @last_error
        return send_request_failed(command,request_hash) 
      end
      retry
    rescue IO::EAGAINWaitWritable
      retry_count+=1
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        p   @last_error
        return send_request_failed(command,request_hash) 
      end
      retry
      rescue  Timeout::Error 
      retry_count+=1
            if retry_count > @retry_count_limit
              @last_error="Timeout on Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
              p   @last_error
              return send_request_failed(command,request_hash) 
            end
            retry
    rescue Errno::ECONNRESET
      if reopen_registry_socket == true
        retry_count+=1
        if retry_count > @retry_count_limit
          @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
          p   @last_error
          return send_request_failed(command,request_hash) 
        end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    rescue Errno::EPIPE
      if reopen_registry_socket == true
        retry_count+=1
        if retry_count > @retry_count_limit
          @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
          p   @last_error
          return send_request_failed(command,request_hash) 
        end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    rescue EOFError
      if reopen_registry_socket == true
        retry_count+=1 
        if retry_count > @retry_count_limit
           @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
           p   @last_error
           return send_request_failed(command,request_hash) 
         end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
      rescue Exception=>e
        p "Exception"
        p e.to_s
        p e.backtrace.to_s
      if reopen_registry_socket == true
              retry_count+=1 
              if retry_count > @retry_count_limit
                 @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
                 p   @last_error
                 return send_request_failed(command,request_hash) 
               end
              retry
            else
              return  send_request_failed(command,request_hash) 
            end
        
    end
    status = Timeout::timeout(15) {
    result_hash = wait_for_reply(@registry_socket)
    }
    
    return result_hash
    
    rescue  Timeout::Error 
    @last_error="Timeout waiting for reply"
    return send_request_failed(command,request_hash) 
   
  end

  def reopen_registry_socket
#    if @registry_socket.is_open?
#      @registry_socket.close
#    end
    p :reopen_socket
      begin
        @registry_socket = open_socket(@server,@port)
        if registry_socket.is_a?(String)
          
          return force_registry_start
        end
        return true
      rescue Exception=>e
        @last_error="Failed to Reopen Connection to " + @server.to_s + ":" + @port.to_s + e.to_s
        return false
      end   
     
  end

  def force_registry_start
  end
  
  def open_socket(host,port)
    require 'socket.rb'
    begin
      BasicSocket.do_not_reverse_lookup = true
      socket = TCPSocket.new(host,port)   
    return socket
      rescue Exception=>e
         @last_error="Failed to open Connection to " + host.to_s + ":" + port.to_s + e.to_s
         p @last_error
    end
  end
end