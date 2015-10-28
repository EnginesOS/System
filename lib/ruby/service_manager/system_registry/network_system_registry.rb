require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class NetworkSystemRegistry < ErrorsApi
  require 'yaml'
  require 'timeout'

  attr_accessor :port,
                :retry_count_limit


  def initialize(core_api)
    @retry_count_limit = 5
    @core_api = core_api
    @port = SystemConfig.RegistryPort
    @registry_socket = open_socket(registry_server_ip, @port)
  end

  def api_shutdown
    @registry_socket.shutdown
    @registry_socket.close
    p "Closed Socket"
  end
  
  def registry_server_ip
   io =  @core_api.get_registry_ip
   p io.to_s
   return io
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
    mesg_lng_str = mesg_data.slice(0, end_tag_indx)
    mesg_len = mesg_lng_str.to_i
    end_byte = total_length - end_tag_indx
    message_request = mesg_data.slice(end_tag_indx + 1, end_byte + 1)
    p :first_chunk
    p message_request.to_s + ':' + mesg_len.to_s
    return message_request, mesg_len
  end

  def wait_for_reply
    response_hash = nil
    first_bytes = true
    begin
      mesg_data = registry_socket.read_nonblock(32_768)
    rescue IO::EAGAINWaitReadable
      retry
    rescue EOFError
      reopen_registry_socket
      retry
    end
    if first_bytes == true
      message_response, mesg_len = process_first_chunk(mesg_data)
      first_bytes = false
    end
   # p 'got ' + message_response.size.to_s + ' of ' + mesg_len.to_s
    while message_response.size < mesg_len
      begin
        mesg_data = registry_socket.read_nonblock(32768)
        message_response += mesg_data
     #   p 'got ' + message_response.size.to_s + ' of ' + mesg_len.to_s
      rescue IO::EAGAINWaitReadable
        retry
      rescue EOFError
        p :eof
        break
      rescue StandardError => e
      log_exception(e)  
        return nil
      end
    end
    if message_response.size > mesg_len
      p :GOT_MORE
      p message_response[mesg_len, message_response.size]
      registry_socket.ungetbyte(message_response[mesg_len, message_response.size])
    message_response = message_response[0, mesg_len]
    end
p :response
p message_response
    return nil if message_response.nil? 
    p 'read ' + message_response.size.to_s + ' Bytes'
    response_hash = YAML.load(message_response)
    unless response_hash[:reply_object].nil? || response_hash == ''
      response_hash[:reply_object] = YAML.load(response_hash[:reply_object])
    end
   p :replay_hash
p response_hash.to_s
p :reply_object_to_s
    p response_hash[:reply_object].to_s
    log_error_mesg(response_hash[:last_error], response_hash) if !response_hash.key?(:result) || response_hash[:result] != 'OK'
    return response_hash
  rescue StandardError => e
    log_exception(e)
    p :error_with_message_response
    p message_response.to_s
    return response_hash
  end

  def build_mesg(mesg_str)
    header = mesg_str.to_s.size
    return header.to_s + ',' + mesg_str.to_s
  end

  def send_request(command, params)
    retry_count = 0
    def send_request_failed(command, params)
      SystemUtils.log_error_mesg('Failed to send command ' + command + ' with:' + @last_error, params)
    end
    request_hash = {}
    request_hash[:value] = params
    request_hash[:command] = command
    request_yaml = request_hash.to_yaml
    mesg_str = build_mesg(request_yaml)

    begin
      unless registry_socket.is_a?(TCPSocket)
        unless reopen_registry_socket.is_a?(TCPSocket)
          log_error_mesg('Failed to reopen registry connection',registry_socket)
          return send_request_failed(command, request_hash)
        end
      end
      status = Timeout.timeout(SystemConfig.registry_connect_timeout) {
        registry_socket.read_nonblock(0)
        registry_socket.send(mesg_str, 0)
      }
       p :sent
       p mesg_str
    rescue Errno::EIO
      retry_count += 1
      p :send_EIO
      if retry_count > @retry_count_limit
        log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
        return send_request_failed(command, request_hash)
      end
      retry
    rescue IO::EAGAINWaitWritable
      p :send_EAGAINWaitWritable
      retry_count += 1
      if retry_count > @retry_count_limit
        log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
        return send_request_failed(command, request_hash)
      end
      retry
    rescue  Timeout::Error
      p :send_Error_to
      retry_count += 1
      if retry_count > @retry_count_limit
        log_error_mesg(@last_error = 'Timeout on Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
        return send_request_failed(command, request_hash)
      end
      retry
    rescue Errno::ECONNRESET
      p :send_ECONNRESET
      if reopen_registry_socket == true
        retry_count += 1
        if retry_count > @retry_count_limit
          log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
          return send_request_failed(command, request_hash)
        end
        retry
      else
        return send_request_failed(command, request_hash)
      end
    rescue Errno::EPIPE
      p :send_EPIPE
      if reopen_registry_socket == true
        retry_count += 1
        if retry_count > @retry_count_limit
          log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
          return send_request_failed(command, request_hash)
        end
        retry
      else
        return send_request_failed(command, request_hash)
      end
    rescue EOFError
      p :send_EOFError
      if reopen_registry_socket
        retry_count += 1
        if retry_count > @retry_count_limit
          log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
          return send_request_failed(command, request_hash)
        end
        retry
      else
        return send_request_failed(command, request_hash)
      end
    rescue StandardError => e
      p 'send_Exception'
      p e.to_s
      p e.backtrace.to_s
      if !reopen_registry_socket
        retry_count += 1
        if retry_count > @retry_count_limit
          log_error_mesg('Failed to Reopen Connection to ' + registry_server_ip.to_s + ':' + @port.to_s + 'After ' + retry_count.to_s + ' Attempts', request_hash)
          return send_request_failed(command, request_hash)
        end
        retry
      else
        return send_request_failed(command, request_hash)
      end
    end
    result_hash = false
    Timeout::timeout(SystemConfig.registry_connect_timeout) {
      result_hash = wait_for_reply
    }
    return result_hash
  rescue Timeout::Error
    log_error_mesg('Timeout waiting for reply.. retried  ' + retry_count.to_s + ' Times', request_hash)
    return send_request_failed(command, request_hash)
  end

  def reopen_registry_socket
    log_error_mesg("Registry reopen",self)
    p :REopen_socket
    @registry_socket.close if @registry_socket.is_a?(TCPSocket)
      @registry_socket = open_socket(registry_server_ip, @port)
     unless @registry_socket.is_a?(TCPSocket)
#        return log_error_mesg("failed_forced_registry_restart", @registry_socket) if !force_registry_restart
#        @registry_socket = open_socket(registry_server_ip, @port)        
        return log_error_mesg("failed_connection_after_forced_registry_restart", @registry_socket) if @registry_socket.is_a?(String)
      end
      return @registry_socket
    rescue StandardError => e
     log_exception(e)
  end
  
  def registry_socket
 return @registry_socket if @registry_socket.is_a?(TCPSocket) 
    @registry_socket = open_socket(registry_server_ip, @port)
   return @registry_socket     
end
   
  def force_registry_restart
    log_error_mesg("FORCE REGISTRY RESTART", self)
     p "FORCE REGISTRY RESTART"
    @core_api.force_registry_restart
  end

  def open_socket(host, port)
    require 'socket.rb'
    begin
      p :userin_host
      p host
      p :using_port
      p port
      BasicSocket.do_not_reverse_lookup = true
      socket = TCPSocket.new(host, port)
      while socket.is_a?(TCPSocket) == false do
        sleep 2
        socket = TCPSocket.new(host, port)
        wait += 1
        if wait > 20
          return force_registry_restart unless socket.is_a?(TCPSocket) 
        end
      end
      return force_registry_restart unless socket.is_a?(TCPSocket) 
      return socket
    rescue StandardError => e
      log_exception(e) unless e.to_s.include?('Connection refused')
      return false     
    end
  end
end
