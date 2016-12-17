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
      @parser = Yajl::Parser.new(:symbolize_keys => true)
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
      return true unless @io_stream.nil?
      return false
    end

    def process_response()
      lambda do |chunk , c , t|
        begin
          #hash = JSON.parse(chunk)
          @parser.parse(chunk) do |hash|
            @builder.log_build_output(hash[:stream]) if hash.key?(:stream)
            @builder.log_build_errors(hash[errorDetail]) if hash.key?(:errorDetail)
          end

        rescue StandardError =>e
          STDERR.puts( ' parse build res EOROROROROR ' + chunk.to_s + ' : ' +  e.to_s)

        end
      end
    rescue StandardError =>e
      STDERR.puts( ' parse build res EOROROROROR ' + chunk.to_s + ' : ' +  e.to_s)
      return
    end

    def process_request(*args)
      @io_stream.read(Excon.defaults[:chunk_size]).to_s
    rescue StandardError => e
      STDERR.puts('PROCESS REQUEST got nilling')
      return nil
    end
  end

  def build_engine(engine_name, build_archive_filename, builder)
    options =  build_options(engine_name)
    header = {}
    header['X-Registry-Config'] = get_registry_auth
    header['Content-Type'] = 'application/tar'
    header['Accept-Encoding'] = 'gzip'
    header['Accept'] = '*/*'
    header['Content-Length'] = File.size(build_archive_filename).to_s
    stream_handler = DockerStreamHandler.new(nil, builder) #File.new(build_archive_filename,'r'))
    return post_stream_request('/build' , options, stream_handler,  header, File.read(build_archive_filename) )
  rescue StandardError => e
    log_exception(e)
  end

end