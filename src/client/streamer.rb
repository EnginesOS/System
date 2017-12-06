class Streamer
  attr_accessor  :i_stream, :stream
  def initialize(istream)
    @stream = nil
    @i_stream = istream
  end

  def close
    @i_stream.close unless @i_stream.nil?
  end

  def is_hijack?
    true
  end

  def has_data?
    if @i_stream.nil? || @i_stream.closed? 
      false
    else
      true
    end
  end

  def process_response()
    lambda do |chunk , c , t|
      puts(chunk.to_s)
    end
  end

  def  process_request(stream_reader)
    @stream_reader = stream_reader
    write_thread = nil
    read_thread = nil
    lambda do |ssl_socket |
      socket = ssl_socket.io
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
          STDERR.puts('Socket ' + socket.inspect)       
          while chunk = socket.readpartial(32768)
            puts chunk.to_s
          end
        rescue EOFError
          write_thread.kill
        rescue StandardError => e
          STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
        write_thread.kill
      end
      STDERR.puts('JOINS')
      write_thread.join unless write_thread.nil?
      read_thread.join unless read_thread.nil?
      @stream_reader.o_stream.close unless @stream_reader.o_stream.nil?
      @stream_reader.i_stream.close unless @stream_reader.i_stream.nil?
    end
  rescue StandardError => e
    STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
    write_thread.kill unless write_thread.nil?
    read_thread.kill unless read_thread.nil?
  end

  #  def process_request(*args)
  #    STDERR.puts('readin ' + @i_stream.to_s)
  #    @i_stream.read(Excon.defaults[:chunk_size]).to_s
  #  rescue StandardError
  #    STDERR.puts('readin ' + @i_stream.inspect)
  #    STDERR.puts('PROCESS REQUEST got nilling')
  #    nil
  #  end
end

#    def initialize(stream)
#      @io_stream = stream
#      @stream = nil
#    end
#    attr_accessor :stream
#
#    def close
#      @io_stream.close unless @io_stream.nil?
#      @stream.reset unless @stream.nil?
#    end
#
#    def is_hijack?
#      true
#    end
#
#    def has_data?
#      if @io_stream.nil?
#        false
#      else
#        true
#      end
#    end
#
#    def process_response()
#      lambda do |chunk , c , t|
#        begin
#          puts chunk.to_s
#        end
#      end
#    rescue StandardError =>e
#      STDERR.puts( ' parse build res EOROROROROR ||' + chunk.to_s + '|| ' +  e.to_s)
#    end
#
##    def process_request(*args)
##      STDERR.puts('readin ')
##      @io_stream.read(Excon.defaults[:chunk_size]).to_s
##    rescue StandardError
##      STDERR.puts('PROCESS REQUEST got nilling')
##      nil
##    end
#
#  def process_request(stream_reader) #data , result, ostream=nil, istream=nil)
#      @stream_reader = stream_reader
#      lambda do |socket|
#        write_thread = Thread.start do
#          write_thread[:name] = 'docker_stream_writer'
#          begin
#            unless @stream_reader.i_stream.nil?
#              STDERR.puts('COPY STREAMS ')
#              IO.copy_stream(@stream_reader.i_stream, socket) unless @stream_reader.i_stream.eof?
#            else
#              STDERR.puts('send data:' + stream_reader.data.class.name)
#              unless stream_reader.data.nil? ||  stream_reader.data.length == 0
#                if stream_reader.data.length < Excon.defaults[:chunk_size]
#                  STDERR.puts('send data as one chunk ' + stream_reader.data.to_s)
#                  socket.send(stream_reader.data, 0)
#                  stream_reader.data = ''
#                else
#                  STDERR.puts('send data as chunks ')
#                  while stream_reader.data.length != 0
#                    if stream_reader.data.length < Excon.defaults[:chunk_size]
#                      socket.send(stream_reader.data.slice!(0, Excon.defaults[:chunk_size]), 0)
#                    else
#                      socket.send(stream_reader.data, 0)
#                      stream_reader.data = ''
#                    end
#                  end
#                end
#              end
#            end
#            STDERR.puts('CLSING')
#            socket.close_write
#            STDERR.puts('CLSINGED')
#          rescue StandardError => e
#            STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
#          end
#        end
#        read_thread = Thread.start do
#          read_thread[:name] = 'docker_stream_reader'
#          begin
#            while chunk = socket.readpartial(32768)
#                puts chunk.to_s
#            end
#          rescue EOFError
#            write_thread.kill
#          rescue StandardError => e
#            STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
#          end
#          write_thread.kill
#        end
#        STDERR.puts('JOINS')
#        write_thread.join
#        read_thread.join
#        @stream_reader.o_stream.close unless @stream_reader.o_stream.nil?
#        @stream_reader.i_stream.close unless @stream_reader.i_stream.nil?
#      end
#    rescue StandardError => e
#
#      STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
#    end
#
#  end