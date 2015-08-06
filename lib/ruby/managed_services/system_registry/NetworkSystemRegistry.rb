class NetworkSystemRegistry

  require 'json'
 attr_accessor :server,
                :port,
                :retry_count_limit,
                :last_error
                
  def initialize(server,port)
    @retry_count_limit=20

    @registry_socket = open_socket(server,port)    
    
    if @registry_socket.is_a?(String) == true
      p @registry_socket.to_s
      return nil
    end

    @server= server
    @port=port
  end

 

 

#  def convert_json_message_to_hash(request)
#    require 'json'
#    hash_request = JSON.parse(request)
#    return  symbolize_top_level_keys(hash_request)
#  rescue
#    return nil
#  end

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
      # while socket.is_open? ==true
      #blocking read
      #readup to first ,
      #get count
      #sub traact bytes already read and read until the rest.
      #save next segment if there is any (or stay sync)
      first_bytes = socket.read_nonblock(32768)

      end_tag_indx = first_bytes.index(',')

      mesg_lng_str = first_bytes.slice(0,end_tag_indx)

      mesg_len =  mesg_lng_str.to_i
      p :mesg_len
      p mesg_len
      total_length = first_bytes.size
      end_byte =  total_length - end_tag_indx
      messege_response = first_bytes.slice(end_tag_indx+1,end_byte)

      while messege_response.size < mesg_len
        begin
          more = socket.read_nonblock(32768)
          messege_response = messege_response + more
        rescue IO::EAGAINWaitReadable
          retry
        end
      end

    rescue IO::EAGAINWaitReadable
      retry
    end

    response_hash = convert_json_message_to_hash(messege_response)

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

      @registry_socket.write(mesg_str)
      
    rescue Errno::EIO
      retry_count+=1
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        return send_request_failed(command,request_hash) 
      end
      retry
    rescue IO::EAGAINWaitWritable
      retry_count+=1
      if retry_count > @retry_count_limit
        @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
        return send_request_failed(command,request_hash) 
      end
      retry
    rescue Errno::ECONNRESET
      if reopen_registry_socket == true
        retry_count+=1
        if retry_count > @retry_count_limit
          @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + "After " + retry_count.to_s + " Attempts"
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
          return send_request_failed(command,request_hash) 
        end
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    rescue EOFError
      if reopen_registry_socket == true
        retry_count+=1 
        retry
      else
        return  send_request_failed(command,request_hash) 
      end
    end
    result_hash = wait_for_reply(@registry_socket)
    return result_hash
  end

  def reopen_registry_socket
    if @registry_socket.is_open?
      @registry_socket.close
    end
      begin
        @registry_socket = open_socket(@host,@port)
        return true
      rescue Exception=>e
        @last_error="Failed to Reopen Connection to " + @host.to_s + ":" + @port.to_s + e.to_s
        return false
      end   
  end

  def open_socket(host,port)
    require 'socket.rb'
    begin
      BasicSocket.do_not_reverse_lookup = true
      socket = TCPSocket.new(host,port)   
    return socket
      rescue Exception=>e
         @last_error="Failed to open Connection to " + host.to_s + ":" + port.to_s + e.to_s
    end
  end
end