module DockerUtils
  def self.process_request(stream_reader) #data , result, ostream=nil, istream=nil)
    @stream_reader = stream_reader
    return_result = @stream_reader.result
    write_thread = nil
    read_thread = nil
    lambda do |socket|
      write_thread = Thread.start do
        write_thread[:name] = 'docker_stream_writer'
        begin
          unless @stream_reader.i_stream.nil?
            unless @stream_reader.i_stream.is_a?(StringIO)
              STDERR.puts('COPY STREAMS ')
              IO.copy_stream(@stream_reader.i_stream, socket) unless @stream_reader.i_stream.eof?
            else
              STDERR.puts('String IO')
              eof = false
              while eof == false
                begin
                  data = nil
                  data = @stream_reader.i_stream.read_nonblock(Excon.defaults[:chunk_size])
                  STDERR.puts('String IO bytes' + data.length.to_s)
                  break if socket.closed
                  socket.send(data, 0) unless data.nil?
                rescue EOFError
                  eof = true
                  break if socket.closed
                  socket.send(data, 0) unless data.nil?
                  next
                rescue IO::WaitReadable
                  break if socket.closed
                  socket.send(data, 0) unless data.nil?
                  IO.select([@stream_reader.i_stream])
                  retry
                end
              end
            end
          else
            STDERR.puts('send data:' + stream_reader.data.to_s)
            STDERR.puts('send data:' + stream_reader.data.class.name) unless stream_reader.data.nil?
            unless stream_reader.data.nil? ||  stream_reader.data.length == 0
              if stream_reader.data.length < Excon.defaults[:chunk_size]             
                socket.send(stream_reader.data, 0)
                STDERR.puts('sent data as one chunk ' + stream_reader.data.to_s)
                stream_reader.data = ''
              else
                #    STDERR.puts('send data as chunks ')
                while stream_reader.data.length != 0
                  if stream_reader.data.length > Excon.defaults[:chunk_size]
                    socket.send(stream_reader.data.slice!(0, Excon.defaults[:chunk_size]), 0)
                  else
                    socket.send(stream_reader.data, 0)
                    stream_reader.data = ''
                  end
                end
              end
            end
          end
          socket.close_write
        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
      end
      read_thread = Thread.start do
        read_thread[:name] = 'docker_stream_reader'
        begin
          while chunk = socket.readpartial(32768)
            if @stream_reader.o_stream.nil?
              DockerUtils.docker_stream_as_result(chunk, return_result)
              STDERR.puts("read srea")
            else
              STDERR.puts("read chuck")
             
              r = DockerUtils.decode_from_docker_chunk(chunk)
              @stream_reader.o_stream.write(r[:stdout]) unless r.nil?
              return_result[:stderr] = return_result[:stderr].to_s + r[:stderr].to_s
            end
          end
          STDERR.puts("read doen")
        rescue EOFError
          STDERR.puts(e.to_s + ':EEOOFF' + e.backtrace.to_s)        
        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
      end
      write_thread.join unless write_thread.nil?
      read_thread.join unless read_thread.nil?
      @stream_reader.o_stream.close unless @stream_reader.o_stream.nil?
      @stream_reader.i_stream.close unless @stream_reader.i_stream.nil?
      STDERR.puts("Closed")
    end
  rescue StandardError => e
    STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
    write_thread.kill unless write_thread.nil?
    read_thread.kill unless read_thread.nil?
  end

  def self.decode_from_docker_chunk(chunk, binary = true)
    r = {
      stderr: '',
      stdout: ''
    }
    self.docker_stream_as_result(chunk, r, binary)
    r
  end

  def self.docker_stream_as_result(chunk, result, binary = true)

    #  def data_length(l)
    #    l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
    #  end
    unmatched = false
    unless result.nil?
      result[:stderr] = '' unless result.key?(:stderr)
      result[:stdout] = '' unless result.key?(:stdout)
      cl = 0
      unless chunk.nil?
        while chunk.length > 0
          if chunk[0].nil?
            return result if chunk.length == 1
            STDERR.puts('Skipping nil ')
            chunk = chunk[1..-1]
            next
          end
          if chunk.start_with?("\u0001\u0000\u0000\u0000")
            dst = :stdout
            l = chunk[0..7].unpack('C*')
            cl = l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
            chunk = chunk[8..-1]
            STDERR.puts('STDOUT ' + cl.to_s + ':' + chunk.length.to_s)
          elsif chunk.start_with?("\u0002\u0000\u0000\u0000")
            dst = :stderr
            l = chunk[0..7].unpack('C*')
            cl = l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
            STDERR.puts('STDERR ' + cl.to_s )
            chunk = chunk[8..-1]
          elsif chunk.start_with?("\u0000\u0000\u0000\u0000")
            dst = :stdout
            chunk = chunk[8..-1]
            STDERR.puts('\0\0\0')
          else
            STDERR.puts('UNMATCHED ' +  chunk.to_s)#.length.to_s)
            dst = :stdout
            unmatched = true
          end
          return result if chunk.nil?
          unless unmatched == true
            length = cl
          else
            length = chunk.length
          end
          if length > chunk.length
            STDERR.puts('WARNING length > actual' + length.to_s + ' bytes length .  actual ' + chunk.length.to_s)
            length = chunk.length
          end
          #   STDERR.puts('len ' + length.to_s + ' bytes length .  actual ' + r.length.to_s)
result[dst] += chunk[0..length-1]
          chunk = chunk[length..-1]
          if chunk.length > 0
            STDERR.puts('Continuation')
          end
        end
      end
      # result actually set elsewhere after exec complete
      result[:result] = 0
      unless binary
        result[:stdout].force_encoding(Encoding::UTF_8) unless result[:stdout].nil?
        result[:stderr].force_encoding(Encoding::UTF_8) unless result[:stderr].nil?
      end
    end
    result
  end
end