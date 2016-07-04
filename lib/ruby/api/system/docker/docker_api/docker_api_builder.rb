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

  
  def build_engine(engine_name, build_archive_filename, builder)
    options =  build_options(engine_name)
    header = {}
    header['X-Registry-Config'] = get_registry_auth
    header['Content-Type'] = 'application/tar'
    header['Accept-Encoding'] = 'gzip'
    header['Transfer-Encoding'] = 'chunked'   
    
    req = Net::HTTP::Post.new('/build?' + options, header)
    req.content_length = File.size(build_archive_filename)
    

      req.body = File.read(build_archive_filename)
   
    
    Net::HTTP.start('172.17.0.1', 2375)  do |http|
       
        http.request(req) { |resp|
          resp.read_body do |chunk|
            #hash = parser.parse(chunk) do |hash|
             STDERR.puts( 'START ' + chunk)
            #end
            response_parser.parse(chunk) do |hash |
               if hash.key?('stream')
                 builder.log_build_output(hash['stream'])
               elsif hash.key?('error')
                 builder.log_build_errors(hash['error'])
               else
                 STDERR.puts( 'EOROROROROR ' + hash.to_s)
               end
                  end
          end
        }
      out_f.close
    end
      rescue StandardError => e
        log_exception(e)
      end
  
end