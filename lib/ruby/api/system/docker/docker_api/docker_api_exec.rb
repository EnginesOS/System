module DockerApiExec
  
  def docker_exec(container, commands, log_error = true, data=nil)
    
      r = create_docker_exec(container, commands)
    
      return r unless r.is_a?(Hash)
  
      exec_id = r['Id']
      request_params = {}
      request_params["Detach"] = false
      request_params["Tty"] = true
      request = '/exec/' + exec_id + '/start'
    initheader = {'Transfer-Encoding' => 'chunked', 'content-type' => 'application/octet-stream' }
      
        req = Net::HTTP::Post.new(uri, initheader)
      #r = make_post_request(request, container, request_params, false , data)
    perform_data_request(req, container, false, data)
      STDERR.puts('EXEC RESQU ' + r.to_s)
      return r if r.is_a?(EnginesError)
      docker_stream_as_result(r)
   
    rescue StandardError => e
      STDERR.puts('DOCKER EXECep  ' + container.container_name + ': with :' + request_params.to_s)
      log_exception(e)
    end
    
    
  class DataProducer
      def initialize()
        @mutex = Mutex.new
        @body = ''
        @eof = false
      end
  
      def eof!()
        @eof = true
      end
  
      def eof?()
        @eof
      end
  
      def size
        @body.size
      end
  
      def read(size, offset)
        STDERR.puts(' READ PARAm ' + offset.to_s + ',' + size.to_s + ' from ' + @body )
        if @body.empty? && @eof
          nil
        else
          @mutex.synchronize {
            size =  @body.size - 1  if size >= @body.size
  
            b = @body.slice!(0,size)
            STDERR.puts(' write b ' + b.to_s + ' of ' + size.to_s + ' bytes  remaining str ' + @body.to_s )
            return b
          }
        end
      end
  
      def produce(data)
        @mutex.synchronize {
          @body = data
        }
      end
    end
  
    def perform_data_request(req, container, return_hash, data)
      producer = DataProducer.new
   
      req.content_type = "application/octet-stream" #"text/plain"
      req['Transfer-Encoding'] = 'chunked'
      req.content_length = data.length
      req.body_stream = producer
      t1 = Thread.new do
        producer.produce(data)
        producer.eof!
      end
      docker_socket.start {|http| http.request(req) }
    rescue StandardError => e
      log_exception(e)
    end
    
  def docker_stream_as_result(r)
 h = {}
   h[:stdout] = ''
   h[:stderr] =  ''
       
    while r.length >0
 
     if r[0].start_with?("\u0001\u0000\u0000\u0000")
      dst = :stdout
     elsif r[0].start_with?("\u0002\u0000\u0000\u0000")
       dst = :stderr
     else
       STDERR.puts('START ' + r[0..4].to_s)
      dst = :stdout
     end
 #"\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u000b{\"certs\":[\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\n\"engines\"\n\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0003]}\n
     
   STDERR.puts("CONTENT " + r.to_s)
   p r
     r = r[4..-1]
     STDERR.puts(' R ' + r.to_s)
     size = r[0,3]
 STDERR.puts(' SIZE '  + size.to_s)
     length = size.unpack("N")
 STDERR.puts(' LENGTH '  + size.to_s + ' cn:' + length[0].class.name)
     #length = length[0]
     r = r[4..-1]
     l = r.index("\u0000\u0000\u0000")
     unless l.nil?
     length =  l - 1
     else
       length = r.length
     end
     STDERR.puts(' problem ' + r.to_s + ' has ' + r.length.to_s + ' bytes and length ' + length.to_s ) if r.length < length
     h[dst] += r[0..length-1]
     r = r[length..-1]
     end
 
    # FIXME need to get correct error status and set :stderr if app
    h[:result] = 0
    h
   end
 
   private
   def create_docker_exec(container, commands)
     commands = format_commands(commands)
          
          request_params = {}
          if data.nil?
            request_params["AttachStdin"] = false
            request_params["Tty"] =  false
          else
            request_params["AttachStdin"] = true
            request_params["Tty"] =  true
          end
          request_params[ "AttachStdout"] =  true
          request_params[ "AttachStderr"] =  true
          request_params[ "DetachKeys"] =  "ctrl-p,ctrl-q"
          request_params[ "Cmd"] =  commands
      
          request = '/containers/'  + container.container_id.to_s + '/exec'
          r = make_post_request(request, container, request_params)
          STDERR.puts('DOCKER EXEC ' + r.to_s + ': for :' + container.container_name + ': with :' + request_params.to_s)
          return r
   end
   
     
def format_commands(commands)
   commands = [commands] unless commands.is_a?(Array)
    commands
 end
 
end