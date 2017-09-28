module DockerUtils
  def self.process_request(stream_reader) #data , result, ostream=nil, istream=nil)
    @stream_reader = stream_reader
    return_result = @stream_reader.result
    lambda do |socket|
      write_thread = Thread.start do
        write_thread[:name] = 'docker_stream_writer'
        begin
          unless @stream_reader.i_stream.nil?
            STDERR.puts('COPY STREAMS ')
            IO.copy_stream(@stream_reader.i_stream, socket) unless @stream_reader.i_stream.eof?
          else
            STDERR.puts('send data:' + stream_reader.data.class.name)
            unless stream_reader.data.nil? ||  stream_reader.data.length == 0
              if stream_reader.data.length < Excon.defaults[:chunk_size]
                STDERR.puts('send data as one chunk ' + stream_reader.data.to_s)
                socket.send(stream_reader.data, 0)
                stream_reader.data = ''
              else
                STDERR.puts('send data as chunks ')
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
          STDERR.puts('CLSING')
          socket.close_write
          STDERR.puts('CLSINGED')
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
      STDERR.puts('JOINS')
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

  def self.decode_from_docker_chunk(chunk, binary = true)
    r = {
      stderr: '',
      stdout: ''
    }
    self.docker_stream_as_result(chunk, r, binary)
    r
  end

  def self.docker_stream_as_result(r, h, binary = true)
    unmatched = false
    unless h.nil?
      h[:stderr] = "" unless h.key?(:stderr)
      h[:stdout] = "" unless h.key?(:stdout)
      cl = 0
      unless r.nil?
        while r.length > 0
          if r[0].nil?
            return h if r.length == 1
            #STDERR.puts('Skipping nil ')
            r = r[1..-1]
            next
          end
          if r.start_with?("\u0001\u0000\u0000\u0000")
            dst = :stdout
            l = r [0..7].unpack('C*')
            cl = l[7] + l[6] * 256 + l[5] * 4096 + l[4] * 65536 + l[3] * 1048576
            r = r[8..-1]
            #STDERR.puts('STDOUTn 0001 header ' +  l.to_s + ' realen ' + r.length.to_s + ' chunck len ' + cl.to_s)
          elsif r.start_with?("\u0002\u0000\u0000\u0000")
            dst = :stderr
            r = r[8..-1]
          elsif r.start_with?("\u0000\u0000\u0000\u0000")
            dst = :stdout
            r = r[8..-1]
            STDERR.puts('STDOUT \0\0\0')
          else
            STDERR.puts('UNMATCHED ' + r.length.to_s + ':' + r.to_s)
            dst = :stderr
            unmatched = true
          end
          return h if r.nil?
          unless unmatched == true
            length = cl
          else
            length = r.length
          end
          if length > r.length
            STDERR.puts('length > actual' + length.to_s + ' bytes length .  actual ' + r.length.to_s)
            length = r.length
          end
          STDERR.puts('len ' + length.to_s + ' bytes length .  actual ' + r.length.to_s)
          h[dst] += r[0..length-1]
          r = r[length..-1]
        end
      end
      # result actually set elsewhere after exec complete
      h[:result] = 0
      unless binary
        h[:stdout].force_encoding(Encoding::UTF_8) unless h[:stdout].nil?
        h[:stderr].force_encoding(Encoding::UTF_8) unless h[:stderr].nil?
      end
    end
    h
  end
end