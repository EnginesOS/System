module DockerApiBuilder
  class ArchiveStream
     def initialize(datafile)
       @mutex = Mutex.new
       @file = File.new(datafile,'rb')
       rescue StandardError => e
         log_exception(e)      
     end
     def eof?()
       @file.eof?
     end
 
     def size
       @file.size
     end
 
     def read(r_size, offset)
         @mutex.synchronize {
           return nil if eof?
         r_size = size if r_size > size      
           STDERR.puts('READ ' + r_size.to_s + '/' + size.to_s)
           @file.read(r_size)
         }
  #     end
     end
 
  
   end
  def build_options(engine_name)
    ret_val = 'buildargs={}'
    ret_val = '&cgroupparent='
    ret_val += '&forcerm=1'
    ret_val += '&rm=1'
    ret_val += '&cpuperiod=0'
    ret_val += '&cpuquota=0'
    ret_val += '&cpusetcpus=0'
    ret_val += '&cpushares=0'
    ret_val += '&memory=0'
    ret_val += '&swap=0'
    ret_val += '&dockerfile=Dockerfile'      
    ret_val += '&t=' + engine_name
    
     ret_val
  end
  require "base64"
  def get_auth
    r = {}
    Base64.encode64(r.to_json)
  end
  
  def build_engine(engine_name, build_archive_filename)
    options =  build_options(engine_name)
    header = {}
    header['X-Registry-Config'] = get_auth
    header['Content-Type'] = 'application/tar'
    header['Accept-Encoding'] = 'gzip'
    header['Transfer-Encoding'] = 'chunked'   
    
    req = Net::HTTP::Post.new('/build?' + options, header)
    req.content_length = File.size(build_archive_filename)
    #archive_stream = ArchiveStream.new(build_archive_filename)
#        t1 = Thread.new do
#          archive_stream.set_source(build_archive_filename)
#          
#        end
        req.body_stream = File.new(build_archive_filename,'rb') #archive_stream
        docker_socket.start {|http| http.request(req) 
        STDERR.puts( 'START ' + http.to_s )
        }
      rescue StandardError => e
        log_exception(e)
      end
  
end