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
    end

   def is_hijack?
     false
   end
        def has_data?
          return true unless @io_stream.nil?
          return false
        end
        
    def process_response(chunk , c , t)
      STDERR.puts('PROCESS RESPONSE got ' + chunk.to_s)
      begin
        if chunk.start_with?('{"stream":"')
        c_e = chunk.length-3
          chunk = chunk[11..-1]
          @builder.log_build_output(chunk.gsub(/"}$/,''))
        elsif chunk.start_with?('{"errorDetail":"')
        chunk = chunk[16..-1]
        
        @builder.log_build_errors(chunk.gsub(/"}$/,''))
        end
        
#      response_parser.parse(chunk) do |hash |
#                    if hash.key?('stream')
#                      build_fail = false 
#                      @builder.log_build_output(hash['stream'])
#                    elsif hash.key?('errorDetail')
#                      build_fail = true 
#                       
#                      error_mesg = hash['errorDetail']
#                      @builder.log_build_errors(error_mesg)
#                    else
#                      @builder.log_build_errors('EOROROROROR ' + hash.to_s)
#                      STDERR.puts( 'EOROROROROR ' + hash.to_s)
#                    end
#                       end
                  rescue StandardError =>e
        STDERR.puts( ' parse build res EOROROROROR ' + chunk.to_s + ' : ' +  e.to_s)
                    return
                  end
    end
    
    def process_request(*args)
         STDERR.puts('PROCESS REQUEST with ')
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
     

    STDERR.puts( 'build_engine ' +  header.to_s)
    stream_handler = DockerStreamHandler.new(nil, builder) #File.new(build_archive_filename,'r'))
#   
  return post_stream_request('/build' , options, stream_handler,  header, File.read(build_archive_filename) )
  
#    req = Net::HTTP::Post.new('/build?' + options, header)
#    req.content_length = File.size(build_archive_filename).to_s
#    req.body = File.read(build_archive_filename)
#error_mesg = ''
#    Net::HTTP.start('172.17.0.1', 2375)  do |http|
#       build_fail = false 
#        http.request(req) { |resp|
#          resp.read_body do |chunk|
#            #hash = parser.parse(chunk) do |hash|
#             STDERR.puts( 'START ' + chunk)
#            #end
#             begin
#            response_parser.parse(chunk) do |hash |
#               if hash.key?('stream')
#                 build_fail = false 
#                 builder.log_build_output(hash['stream'])
#               elsif hash.key?('errorDetail')
#                 build_fail = true 
#                  
#                 error_mesg = hash['errorDetail']
#                 builder.log_build_errors(error_mesg)
#               else
#                 builder.log_build_errors('EOROROROROR ' + hash.to_s)
#                 STDERR.puts( 'EOROROROROR ' + hash.to_s)
#               end
#                  end
#             rescue
#               next
#             end
#          end
#        }
#     return  builder.build_failed(error_mesg) if build_fail == true 
#     return true
    #    end
      rescue StandardError => e
        log_exception(e)
      end
  
end