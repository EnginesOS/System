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
         r_size = size - @file.pos  if r_size > size - @file.pos      
           STDERR.puts('READ ' + r_size.to_s + '/' + size.to_s)
           bytes =  @file.read(r_size)
           STDERR.puts('READ ' + bytes.length.to_s)
           bytes
         }
  #     end
     end
 
  
   end
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
    
#        t1 = Thread.new do
#          archive_stream.set_source(build_archive_filename)
#          
#        end
    #    req.body_stream = File.new(build_archive_filename,'rb') #archive_stream
    req.body = File.read(build_archive_filename)
#    STDERR.puts( 'START ' + build_archive_filename.to_s + ' is ' )
#       resp = docker_socket.request(req) 
#    resp.read_body do | seg|
#      STDERR.puts( 'START ' +  seg.to_s)
#    end
    
    Net::HTTP.start('172.17.0.1', 2375)  do |http|
       
        http.request(req) { |resp|
          resp.read_body do |chunk|
            #hash = parser.parse(chunk) do |hash|
             STDERR.puts( 'START ' + chunk)
            #end
            response_parser.parse(chunk) do |hash |
              STDERR.puts( 'STDIO ' + hash['stream'].to_s) if hash.key?('stream')
                 
                  end
          end
        }
    
    end
      rescue StandardError => e
        log_exception(e)
      end
  
end