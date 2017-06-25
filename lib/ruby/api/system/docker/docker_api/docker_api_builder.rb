module DockerApiBuilder
  def build_options(engine_name)
    ret_val = 'buildargs={}'
    ret_val += '&cgroupparent='
    ret_val += '&forcerm=1'
    ret_val += '&rm=1'
    ret_val += '&cpuperiod=0'
    ret_val += '&cpuquota=0'
    ret_val += '&cpusetcpus='
    ret_val += '&cpusetmems='
    ret_val += '&cpushares=0'
    ret_val += '&memory=0'
    ret_val += '&memswap=0'
    ret_val += '&dockerfile=Dockerfile'
    ret_val += '&ulimits=null'
    ret_val += '&t=' + engine_name
    ret_val
  end

  class DockerStreamHandler
    def initialize(stream, builder)
      @io_stream = stream
      @builder = builder
      @stream = nil
     # @parser = FFI_Yajl::Parser.new({:symbolize_keys => true})
       @parser = Yajl::Parser.new({:symbolize_keys => true})
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
          chunk.sub!(/}[ \n\r]*$/,'}')
          chunk.sub!(/^[ \n\r]*{/,'{')
          STDERR.puts(' Chunk |' + chunk.to_s + '|')
          hash = @parser.parse(chunk)  #do |hash|
          # hash = deal_with_json(chunk)
          @builder.log_build_output(hash[:stream].force_encoding(Encoding::UTF_8)) if hash.key?(:stream)
          if hash.key?(:errorDetail)
            @builder.log_build_errors(hash[:errorDetail][:message])
            if hash[:errorDetail].key?(:error)
              log_build_errors('Engine Build Aborted Due to:' + hash[:errorDetail][:error].to_s)
              @builder.post_failed_build_clean_up
            end
          end
        rescue StandardError =>e
          STDERR.puts( ' parse build res EOROROROROR |' + chunk.to_s + '| ' +  e.to_s)
        end
      end
    rescue StandardError =>e
      STDERR.puts( ' parse build res EOROROROROR ||' + chunk.to_s + '|| ' +  e.to_s)
    end

    def process_request(*args)
      @io_stream.read(Excon.defaults[:chunk_size]).to_s
    rescue StandardError
      STDERR.puts('PROCESS REQUEST got nilling')
      nil
    end
  end

  def build_engine(engine_name, build_archive_filename, builder)
    stream_handler = nil
    options =  build_options(engine_name)
    header = {
      'X-Registry-Config' => registry_root_auth,
      'Content-Type' => 'application/tar',
      'Accept-Encoding' => 'gzip',
      'Accept' => '*/*',
      'Content-Length' => File.size(build_archive_filename).to_s
    }
    stream_handler = DockerStreamHandler.new(nil, builder) #File.new(build_archive_filename,'r'))
    r =  post_stream_request('/build' , options, stream_handler, header, File.read(build_archive_filename) )
    stream_handler.close
    r
  rescue StandardError => e
    stream_handler.close unless stream_handler.nil?
    raise e
  end

end