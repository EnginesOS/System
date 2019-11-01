module DockerApiBuilder
  
  def build_options(engine_name)
    ret_val = "t=#{engine_name}"
    ret_val += '&buildargs={}'
    #  ret_val += '&cgroupparent='
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
    #ret_val += '&ulimits=null'
    ret_val
  end

  class DockerStreamHandler
    def initialize(stream)
      @io_stream = stream
    end

    def parser
      @parser ||= FFI_Yajl::Parser.new({symbolize_keys: true, sym_check_utf8: false})
    end

    def close
      @io_stream.close unless @io_stream.nil?
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
          #FIXME stuff chunck in stringio and use streaming parser on the stringio
          STDERR.puts("Chunk::#{chunk}")
          if chunk.include?('{"stream":"')
            then
            chunk.gsub!(/{"stream":"/,'')
            STDERR.puts("Chunk::#{chunk.gsub(/"}/,'')}")
            builder.log_build_output(chunk.gsub(/"}/,''))
          else
            hash = parser.parse(chunk)  #do |hash|
            #builder.log_build_output(c.force_encoding(Encoding::ASCII_8BIT))
            builder.log_build_output(hash[:stream]) if hash.key?(:stream)
            if hash.key?(:errorDetail)
              builder.log_build_errors(hash[:errorDetail][:message])
              if hash[:errorDetail].key?(:error)
                log_build_errors('Engine Build Aborted Due to:' + hash[:errorDetail][:error].to_s)
                builder.post_failed_build_clean_up
              end
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
      @io_stream.read(Excon.defaults[:chunk_size])
    rescue StandardError
      STDERR.puts('PROCESS REQUEST got nilling')
      nil
    end
    
    def builder
      @builder ||= EngineBuilder.instance
    end
  end

  def build_engine(engine_name, build_archive_filename)
    stream_handler = nil
    options =  build_options(engine_name)
    header = {
      'X-Registry-Config' => registry_root_auth,
      'Content-Type' => 'application/tar',
      'Accept-Encoding' => 'gzip',
      'Accept' => '*/*',
      'Content-Length' => File.size(build_archive_filename).to_s
    }
    stream_handler = DockerStreamHandler.new(nil)
    post_stream_request({ timeout: 300, uri: '/build' , options: options, stream_handler: stream_handler, headers: header, content: File.read(build_archive_filename) } )
  ensure
    stream_handler.close unless stream_handler.nil?
  end

end