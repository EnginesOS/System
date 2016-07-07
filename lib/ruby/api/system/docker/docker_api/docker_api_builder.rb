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
    def initialize(stream)
      @io_stream = stream
    end

   def is_hijack?
     false
   end
        def has_data?
          return true unless @io_stream.nil?
          return false
        end
        
    def process_response(*args)
      STDERR.puts('PROCESS RESPONSE got ' + args.to_s)
    end
    def process_request(*args)
         STDERR.puts('PROCESS REQUEST got ' + args.to_s)
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

    header['Content-Length'] = File.size(build_archive_filename)
    header['Transfer-Encoding'] = 'chunked'   
    req = Net::HTTP::Post.new('/build?' + options, header)
    req.content_length = File.size(build_archive_filename)
    STDERR.puts( 'build_engine ' +  header.to_s)
    #stream_handler = DockerStreamHandler.new(File.new(build_archive_filename,'r'))
   
  #return  post_stream_request('/build?' + options, stream_handler,  header )
    req.body = File.read(build_archive_filename)
error_mesg = ''
    Net::HTTP.start('172.17.0.1', 2375)  do |http|
       build_fail = false 
        http.request(req) { |resp|
          resp.read_body do |chunk|
            #hash = parser.parse(chunk) do |hash|
             STDERR.puts( 'START ' + chunk)
            #end
             begin
            response_parser.parse(chunk) do |hash |
               if hash.key?('stream')
                 build_fail = false 
                 builder.log_build_output(hash['stream'])
               elsif hash.key?('errorDetail')
                 build_fail = true 
                  
                 error_mesg = hash['errorDetail']
                 builder.log_build_errors(error_mesg)
               else
                 builder.log_build_errors('EOROROROROR ' + hash.to_s)
                 STDERR.puts( 'EOROROROROR ' + hash.to_s)
               end
                  end
             rescue
               next
             end
          end
        }
     return  builder.build_failed(error_mesg) if build_fail == true 
     return true
    end
      rescue StandardError => e
        log_exception(e)
      end
  
end