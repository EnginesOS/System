module DockerHijack

  require_relative 'decoder/docker_decoder.rb'

  @@missing=0
  @@dst = :stdout
  def self.process_request(stream_reader) #data , result, stdout_stream=nil, istream=nil)
    @stream_reader = stream_reader
    @decoder = DockerDecoder.new
    return_result = @stream_reader.result
    write_thread = nil
    read_thread = nil
    lambda do |socket|
      write_thread = Thread.start do
        write_thread[:name] = 'docker_stream_writer'
        begin
          unless @stream_reader.i_stream.nil?
            unless @stream_reader.i_stream.is_a?(StringIO)
            #  STDERR.puts('COPY STREAMS ')
              IO.copy_stream(@stream_reader.i_stream, socket) unless  @stream_reader.nil? #@stream_reader.i_stream.eof?
            else
            #  STDERR.puts('String IO')
              eof = false
              while eof == false
                begin
                  data = nil
                #  STDERR.puts('read_nonblock process_request ')
                  data = @stream_reader.i_stream.read_nonblock(Excon.defaults[:chunk_size])
              #    STDERR.puts('String IO bytes' + data.length.to_s)
                  break if socket.closed?
                  socket.send(data, 0) unless data.nil?
                rescue EOFError
                  eof = true
                  STDERR.puts('String IO EOF')
                  break if socket.closed?
                  socket.send(data, 0) unless data.nil?
                  next
                rescue IO::WaitReadable
                  break if socket.closed?
                  socket.send(data, 0) unless data.nil?
                  STDERR.puts('IOSELECT process_request')
                  IO.select([@stream_reader.i_stream])
                  retry
                end
              end
            end
          else
            # STDERR.puts('send data:' + stream_reader.data.to_s)
           # STDERR.puts('send data:' + stream_reader.data.class.name) unless stream_reader.data.nil?
            unless stream_reader.data.nil? || stream_reader.data.length == 0
              if stream_reader.data.length < Excon.defaults[:chunk_size]
                socket.send(stream_reader.data, 0)
            #    STDERR.puts('sent data as one chunk ' )#+ stream_reader.data.to_s)
                stream_reader.data = ''
              else
              #  STDERR.puts('send data as chunks ')
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
          STDERR.puts(e.to_s + ':write:' + e.backtrace.to_s)
        end
      end
      read_thread = Thread.start do
        read_thread[:name] = 'docker_stream_reader'
        begin
        #  STDERR.puts('readpartial process_request')
          while chunk = socket.readpartial(32768)
         #   STDERR.puts("read chunk ", chunk.to_s)
            if @stream_reader.out_stream.nil?
              @decoder.docker_stream_as_result({chunk: chunk, result: return_result})
            else
           #   STDERR.puts("read as stream")
              r = @decoder.decode_from_docker_chunk({chunk: chunk, binary: true, stream: @stream_reader.out_stream})
            end
            return_result[:stderr] = "#{return_result[:stderr]}#{r[:stderr]}" unless r.nil?
          end
        #  STDERR.puts("read doen")
        rescue EOFError => e
          STDERR.puts(e.to_s + ':EEOOFF' )
          next
        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
      end
      write_thread.join unless write_thread.nil?
      read_thread.join unless read_thread.nil?
      @stream_reader.out_stream.close unless @stream_reader.out_stream.nil?
      @stream_reader.i_stream.close unless @stream_reader.i_stream.nil?
      #   STDERR.puts("Closed")
    end
  rescue StandardError => e
    STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
    write_thread.kill unless write_thread.nil?
    read_thread.kill unless read_thread.nil?
  end

end