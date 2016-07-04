module DockerApiBuilder
  class ArchiveStream
     def initialize()
       @mutex = Mutex.new
       @body = ''
       @eof = false
     end
     def eof?()
       @file.eof?
     end
 
     def size
       @file.size
     end
 
     def read(size, offset)
       STDERR.puts(' READ PARAm ' + offset.to_s + ',' + size.to_s + ' from ' + @body )
       if eof?
         nil
       else
         @mutex.synchronize {
           @file.read(size)
         }
       end
     end
 
     def set_source(datafile)
       @mutex.synchronize {  
         @file = File.new(datafile,'r')
       }
     end
   end
  def build_options(engine_name)
    ret_val = {}
    ret_val['forcerm'] = 1
    ret_val['rm'] = 1
    ret_val['cpuperiod'] = 0
    ret_val['cpuquota'] = 0
    ret_val['cpusetcpus'] = 0
    ret_val['cpushares'] = 0
    ret_val['memory'] = 0
    ret_val['swap'] = 0
    ret_val['dockerfile'] = 'Dockerfile'      
    ret_val['t'] = engine_name
    ret_val['X-Registry-Config'] = get_auth
     ret_val
  end
  require "base64"
  def get_auth
    r = {}
    Base64.encode64(r.to_json)
  end
  
  def build_engine(engine_name, build_archive_filename)
    header =  build_options(engine_name)
    header['Content-Type'] = 'application/tar'
    header['Accept-Encoding'] = 'gzip'
    header['Transfer-Encoding'] = 'chunked'   
    
    req = Net::HTTP::Post.new(uri, header)
    req.content_length = build_archive_size
    archive_stream = ArchiveStream.new
    req.body_stream = archive_stream
        t1 = Thread.new do
          archive_stream.set_source(build_archive_filename)
        end
        docker_socket.start {|http| http.request(req) 
        STDERR.puts( 'START ' + http.to_s )
        }
      rescue StandardError => e
        log_exception(e)
      end
  
end