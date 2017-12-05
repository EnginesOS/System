class Streamer
    def initialize(stream)
      @io_stream = stream
      @stream = nil
    end
    attr_accessor :stream

    def close
      @io_stream.close unless @io_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def is_hijack?
      false
    end

    def has_data?
      if @io_stream.nil?
        false
      else
        true
      end
    end

    def process_response()
      lambda do |chunk , c , t|       
        begin
          puts chunk.to_s
        end
      end
    rescue StandardError =>e
      STDERR.puts( ' parse build res EOROROROROR ||' + chunk.to_s + '|| ' +  e.to_s)
    end

    def process_request(*args)
      STDERR.puts('readin ')
      @io_stream.read(Excon.defaults[:chunk_size]).to_s
    rescue StandardError
      STDERR.puts('PROCESS REQUEST got nilling')
      nil
    end
  end