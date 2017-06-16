module DockerUtils
  def self.process_request(stream_reader) #data , result, ostream=nil, istream=nil)
    @stream_reader = stream_reader
    return_result = @stream_reader.result
    lambda do |socket|

      write_thread = Thread.start do
        write_thread[:name] = 'docker_stream_writer'
        begin
          unless @stream_reader.i_stream.nil?
            IO.copy_stream(@stream_reader.i_stream,socket) unless @stream_reader.i_stream.eof?
          else
            unless stream_reader.data.nil? ||  stream_reader.data.length == 0
              if stream_reader.data.length < Excon.defaults[:chunk_size]
                socket.send(stream_reader.data, 0)
                stream_reader.data = ''
              else
                while stream_reader.data.length != 0
                  if stream_reader.data.length < Excon.defaults[:chunk_size]
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
          while chunk = socket.readpartial(16384)
            if  @stream_reader.o_stream.nil?
              DockerUtils.docker_stream_as_result(chunk, return_result)
            else
              r = DockerUtils.decode_from_docker_chunk(chunk)
              @stream_reader.o_stream.write(r[:stdout]) unless r.nil?
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
      @stream_reader.o_stream.close unless @stream_reader.o_stream.nil?
      @stream_reader.i_stream.close unless @stream_reader.i_stream.nil?
    end
  rescue StandardError => e
    write_thread.kill
    read_thread.kill
    STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
  end

  def self.decode_from_docker_chunk(chunk)
    r = {
      stderr: '',
      stdout: ''
    }
    self.docker_stream_as_result(chunk, r)
    r
  end

  def self.docker_stream_as_result(r, h)
    unmatched = false
    unless h.nil?
      h[:stderr] = "" unless h.key?(:stderr)
      h[:stdout] = "" unless h.key?(:stdout)
      while r.length >0
        if r[0].nil?
          return h if r.length == 1
          #STDERR.puts('Skipping nil ')
          r = r[1..-1]
          next
        end
        if r.start_with?("\u0001\u0000\u0000\u0000")
          dst = :stdout
          #   STDERR.puts('STDOUT ' + r.to_s)
          # ls = r[0,7]
          r = r[8..-1]
          #STDERR.puts('STDOUT ' + r.to_s)
        elsif r.start_with?("\u0002\u0000\u0000\u0000")
          dst = :stderr
          #  ls = r[0,7]
          r = r[8..-1]
          # r.slice!(8,r.length-1)

        elsif r.start_with?("\u0000\u0000\u0000\u0000")
          dst = :stdout
          # ls = r[0,7]
          r = r[8..-1]
          #STDERR.puts('STDOUT \0\0\0')
          # r.slice!(8,r.length-1)
        else
          # r = r[7..-1]
          # ls = r[0,7]
          #STDERR.puts('UNMATCHED')
          dst = :stdout
          unmatched = true
        end
        return h if r.nil?
        unless unmatched == true
          next_chunk = r.index("\u0000\u0000\u0000")
          unless next_chunk.nil?
            length =  next_chunk - 1
          else
            length = r.length
          end
        else
          length = r.length
        end
        #   STDERR.puts(' problem ' + r.to_s + ' has ' + r.length.to_s + ' bytes and length ' + length.to_s ) if r.length < length
        h[dst] += r[0..length-1]
        r = r[length..-1]
      end

      # This is actually set elsewhere after exec complete
      h[:result] = 0
      h[:stdout].force_encoding(Encoding::UTF_8) unless h[:stdout].nil?
      h[:stderr].force_encoding(Encoding::UTF_8) unless h[:stderr].nil?
    end
    h
  end
end