class NetworkSystemRegistry
require 'yaml'
require 'timeout'
#  require 'json'
 attr_accessor  :port,
                :retry_count_limit,
                :last_error
                
  def initialize(core_api)
    @retry_count_limit=5
  @core_api = core_api
  server_ip = registry_server_ip
  @port=SysConfig.RegistryPort
  @registry_socket = open_socket(server_ip,@port)    
    
    if @registry_socket.is_a?(String) == true
      p @registry_socket.to_s
      return nil
    end
     
  end

 def registry_server_ip
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

  
def process_first_chunk(mesg_data)

    total_length = mesg_data.size
    end_tag_indx = mesg_data.index(',')
    mesg_lng_str = mesg_data.slice(0,end_tag_indx)
    mesg_len =  mesg_lng_str.to_i
    end_byte =  total_length - end_tag_indx
    message_request = mesg_data.slice(end_tag_indx+1,end_byte+1)

    return message_request , mesg_len
  end
  
  def wait_for_reply(socket)
    response_hash =  nil
    begin
      first_bytes = true
      mesg_data = socket.read_nonblock(32768)

      if first_bytes == true
        message_response, mesg_len = process_first_chunk(mesg_data)
        first_bytes= false
      end
      
      while message_response.size < mesg_len
        begin
          mesg_data = socket.read_nonblock(32768)
          message_response = message_response + mesg_data
        rescue IO::EAGAINWaitReadable
          retry    
        end
      end
      
    rescue EOFError
   
    rescue IO::EAGAINWaitReadable     
      retry
        
  rescue Exception=>e
    p "Exception"
    p e.to_s
    p e.backtrace.to_s
      return nil
    end
    
    if  message_response == nil 
      return nil
    end

    response_hash = YAML::load(message_response)
    if response_hash[:object] != nil
      response_hash[:object] = YAML::load(response_hash[:object])    
    end
        
    return response_hash
    rescue Exception=>e
        p "Exception"
        p e.to_s
        p e.backtrace.to_s
    return response_hash

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
   
      if  @registry_socket.is_a?(String)
          if reopen_registry_socket  == false
            @last_error="Failed to reopen registry connection"
            return send_request_failed(command,request_hash) 
          end
      end
      status = Timeout::timeout(5) {    
          @registry_socket.read_nonblock(0)    
          @registry_socket.send(mesg_str,0)
      }
         
    rescue Errno::EIO
      retry_count+=1
      p :send_EIO
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        p   @last_error
        return send_request_failed(command,request_hash) 
      end
      retry
    rescue IO::EAGAINWaitWritable
      p :send_EAGAINWaitWritable
      retry_count+=1
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        p   @last_error
        return send_request_failed(command,request_hash) 
      end
      retry
      rescue  Timeout::Error 
        p :send_Error_to
      retry_count+=1
            if retry_count > @retry_count_limit
              @last_error="Timeout on Connection to " +  registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
              p   @last_error
              return send_request_failed(command,request_hash) 
            end
            retry
    rescue Errno::ECONNRESET
      p :send_ECONNRESET
      if reopen_registry_socket == true
        retry_count+=1
        if retry_count > @retry_count_limit
          @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
          p   @last_error
          return send_request_failed(command,request_hash) 
        end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    rescue Errno::EPIPE
      p :send_EPIPE
      if reopen_registry_socket == true
        retry_count+=1
        if retry_count > @retry_count_limit
          @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
          p   @last_error
          return send_request_failed(command,request_hash) 
        end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    rescue EOFError
      p :send_EOFError
      if reopen_registry_socket == true
        retry_count+=1 
        if retry_count > @retry_count_limit
           @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
           p   @last_error
           return send_request_failed(command,request_hash) 
         end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
      rescue Exception=>e
        p "send_Exception"
        p e.to_s
        p e.backtrace.to_s
      if reopen_registry_socket == true
              retry_count+=1 
              if retry_count > @retry_count_limit
                 @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
                 p   @last_error
                 return send_request_failed(command,request_hash) 
               end
              retry
            else
              return  send_request_failed(command,request_hash) 
            end
        
    end
    result_hash = false
    status = Timeout::timeout(15) {
#      p :waiting_for_reply
    result_hash = wait_for_reply(@registry_socket)
    }
    
    return result_hash
    
    rescue  Timeout::Error 
        @last_error="Timeout waiting for reply.. retried  " + retry_count.to_s + " Times"
        return send_request_failed(command,request_hash)    
  end

  def reopen_registry_socket
#    if @registry_socket.is_open?
#      @registry_socket.close
#    end
#    p :reopen_socket
      begin
        @registry_socket = open_socket(registry_server_ip,@port)
        if @registry_socket.is_a?(String)
          
          if force_registry_restart == false
            p :failed_forced_registry_restart
            return false
          end
          
          @registry_socket = open_socket(registry_server_ip,@port)
          
          if @registry_socket.is_a?(String)
           p  :failed_connection_after_forced_registry_restart
            return false
          end
        end
        return true
      rescue Exception=>e
        @last_error="Failed to Reopen Connection to " + registry_server_ip.to_s + ":" + @port.to_s + e.to_s
        return false
      end   
     
  end

  def force_registry_restart
    @core_api.force_registry_restart
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