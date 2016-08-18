module DockerUtils
  def self.process_request(data , result, ostream=nil, istream=nil)
    @i_stream = istream
    @o_stream = ostream
    to_send = data
    return_result = result
    STDERR.puts('PROCESS REQUEST init ' + to_send.to_s)
    lambda do |socket|
      STDERR.puts('PROCESS REQUEST Lambda')
      write_thread = Thread.start do
        begin
          STDERR.puts('PROCESS REQUEST write thread ' + to_send.to_s)
          unless @i_stream.nil?
            return socket.close_write if @i_stream.eof?
            IO.copy_stream(@i_stream,socket)
          else
          return socket.close_write if to_send.length == 0
          if to_send.length < Excon.defaults[:chunk_size]
            STDERR.puts('PROCESS REQUEST with single chunk ' + to_send.to_s)
            r = to_send
            to_send = ''
            socket.send(r,0)
            socket.close_write
          else
            while to_send.length != 0
              if to_send.length < Excon.defaults[:chunk_size]
              socket.send(to_send.slice!(0,Excon.defaults[:chunk_size]),0)
              else
                socket.send(r,0)
                to_send = ''
            end
          end
            socket.close_write
          end
          end
        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
      end
      
      read_thread = Thread.start do
        begin
          STDERR.puts('PROCESS REQUEST read thread')
          while chunk = socket.readpartial(16384)
            if  @o_stream.nil?
            DockerUtils.docker_stream_as_result(chunk, return_result)
            STDERR.puts('PROCESS REQUEST read thread' + return_result.to_s)
              else
             r = DockerUtils.decode_from_docker_chunk(chunk)
             @o_stream.write(r[:stdout]) unless r.nil?
              return_result[:stderr] =  return_result[:stderr].to_s + r[:stderr].to_s
            end
          end
        rescue EOFError
          write_thread.kill

        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
        write_thread.kill
      end

      write_thread.join
      read_thread.join
    end
  rescue StandardError => e
    STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )

  end

  
  def self.decode_from_docker_chunk(chunk)
    r = {}
    r[:stderr] = ''
    r[:stdout] = ''
    self.docker_stream_as_result(chunck, r)
    r
end

  def self.docker_stream_as_result(r, h)
    unmatched = false
    return h if r.nil?
    h[:stderr] = "" unless h.key?(:stderr)
    h[:stdout] = "" unless h.key?(:stdout)

    while r.length >0
      if r[0].nil?
        return h if r.length == 1
        r = r[1..-1]
        next
      end
      if r.start_with?("\u0001\u0000\u0000\u0000")
        ls = r[0,7]
        r = r[8..-1]
        STDERR.puts("Stdout CONTENT " + ls.to_s)
        dst = :stdout
      elsif r.start_with?("\u0002\u0000\u0000\u0000")
        dst = :stderr
        ls = r[0,7]
        r = r[8..-1]
        STDERR.puts("StdERR CONTENT "  + ls.to_s)
      elsif r.start_with?("\u0000\u0000\u0000\u0000")
        dst = :stdout
        ls = r[0,7]
        r = r[8..-1]
        STDERR.puts("unlabled stdout CONTENT "  + ls.to_s)
      else
        # r = r[7..-1]
        ls = r[0,7]
        STDERR.puts(" umatched CONTENT "  + ls.to_s)
        dst = :stdout
        unmatched = true
      end

      return h if r.nil?
      unless unmatched == true
        next_chunk = r.index("\u0000\u0000\u0000")
        STDERR.puts("Next Chunk " + next_chunk.to_s)
        unless next_chunk.nil?
          length =  next_chunk - 1
        else
          STDERR.puts('End of string')
          length = r.length
        end
      else
        length = r.length
      end

      #   STDERR.puts(' problem ' + r.to_s + ' has ' + r.length.to_s + ' bytes and length ' + length.to_s ) if r.length < length
      h[dst] += r[0..length-1]
      r = r[length..-1]
      STDERR.puts(' still ave of string ' + r.length.to_s)
    end

    # FIXME need to get correct error status and set :stderr if app
    h[:result] = 0
    h
  end
end