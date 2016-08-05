module DockerApiExec

  require_relative 'docker_utils.rb'
  
  class DockerStreamHandler
    attr_accessor :result
      def initialize(data)
        @data = data
        @result = {}
        @result[:raw] = ''
        @result[:stdout] = ''
        @result[:stderr] = ''
      end
    
     def is_hijack?
       true
     end
          def has_data?
            return false if  @data.nil?
            return false if  @data.length == 0
            return true
          end
          
      def process_response()
        return_result = @result
         lambda do |chunk , c , t|
        DockerUtils.docker_stream_as_result(chunk, return_result)
           return_result[:raw] = return_result[:raw] + chunk.to_s
  STDERR.puts( ' parse build res  ' + chunk.to_s )
          end
     rescue StandardError =>e
          STDERR.puts( ' parse build res EOROROROROR ' + chunk.to_s + ' : ' +  e.to_s + ' ' + e.backtrace.to_s)
                      return
        
      end
    def process_request()
      to_send = @data
      return_result = @result
      STDERR.puts('PROCESS REQUEST init ' + to_send.to_s)
      lambda do |socket|
        STDERR.puts('PROCESS REQUEST Lambda')
        write_thread = Thread.start do 
          begin
      STDERR.puts('PROCESS REQUEST write thread ' + to_send.to_s)
           return socket.close_write if to_send.length == 0
           if to_send.length < Excon.defaults[:chunk_size]
             STDERR.puts('PROCESS REQUEST with single chunk ' + to_send.to_s)
             r = to_send
             to_send = ''
             socket.send(r)
             socket.close_write
           else
             socket.send(to_send.slice!(0,Excon.defaults[:chunk_size]))
           end
          rescue StandardError => e
              STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
          end
        end
        read_thread = Thread.start do
          begin
            STDERR.puts('PROCESS REQUEST read thread')
          while chunk = socket.read_partial(1024)
            DockerUtils.docker_stream_as_result(chunk, return_result)
            STDERR.puts('PROCESS REQUEST read thread' + return_result.to_s)
          end          
         rescue EOFError 
           return
         rescue StandardError => e
            STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
          write_thread.kill
        end
        
        write_thread.join
        read_thread.join
     end
    rescue StandardError => e
      STDERR.puts('PROCESS Execp' + e.to_s + ' ' + e.backtrace.to_s )
      
    end
  end
    
  def docker_exec(container, commands, log_error = true, data=nil)
    have_data = false
    have_data = true unless data.nil?
    
      r = create_docker_exec(container, commands, have_data)
    
      return r unless r.is_a?(Hash)

      exec_id = r[:Id]
      request_params = {}
      request_params["Detach"] = false
      request_params["Tty"] = false
      request = '/exec/' + exec_id + '/start'
    unless have_data == true
      result = {}
      r = post_request(request,  request_params, false )
      return r if r.is_a?(EnginesError)
      return DockerUtils.docker_stream_as_result(r, result)
    end
  #  initheader = {'Transfer-Encoding' => 'chunked', 'content-type' => 'application/octet-stream' }
    request_params["Tty"] = false
    request_params["AttachStdin"] = true
    request_params["AttachStdout"] = true
    request_params["AttachStderr"] = true
      
    stream_handler = DockerStreamHandler.new(data)
    headers = {}
    headers['Content-type'] = 'text/plain'
     
    post_stream_request(request, request_params, stream_handler,  headers  )
    STDERR.puts('EXEC RES ' + stream_handler.result.to_s)
    stream_handler.result
#     req = Net::HTTP::Post.new(request, initheader)
#     
#    perform_data_request(req, container, request_params, data)
#      STDERR.puts('EXEC RESQU ' + r.to_s)
#      return r if r.is_a?(EnginesError)
#      docker_stream_as_result(r)
   
    rescue StandardError => e
      STDERR.puts('DOCKER EXECep  ' + container.container_name + ': with :' + request_params.to_s)
      log_exception(e)
    end
    
    
#  class DataProducer
#      def initialize(data)
#        @mutex = Mutex.new
#        @body = data
#        @eof = false
#      end
#  
#      def eof!()
#        @eof = true
#      end
#  
#      def eof?()
#        @eof
#      end
#  
#      def size
#        @body.size
#      end
#  
#      def read(size, offset)
#        @mutex.synchronize {
#        STDERR.puts(' READ PARAm ' + offset.to_s + ',' + size.to_s + ' from ' + @body )
#        if @body.empty? && @eof
#          nil
#        else
#   
#            size =  @body.size - 1  if size >= @body.size
#  
#            b = @body.slice!(0,size)
#            STDERR.puts(' write b ' + b.to_s + ' of ' + size.to_s + ' bytes  remaining str ' + @body.to_s )
#            return b
#          end
#          }
#       
#      end
#  
#      def produce(data)
#        @mutex.synchronize {
#          @body = data
#          STDERR.puts(' body ' + @body.to_s)
#        }
#      end
#    end
#  

    
    def perform_data_request(req, container, params, data)
      producer = DataProducer.new(data)
#      t1 = Thread.new do
#        producer.produce(data)
#        producer.eof!
#      end
      req.content_type = "application/octet-stream" #"text/plain"
     # req['Transfer-Encoding'] = 'chunked'
     # req.content_length = data.length
      req.body = params.to_json
      
      #req.body_stream = producer

      docker_socket.start {|http| http.request(req) 
      
        docker_socket.write(data)
        
      }
    rescue StandardError => e
      log_exception(e)
    end
    

 
   private
   def create_docker_exec(container, commands, have_data)
     commands = format_commands(commands)
          
          request_params = {}
          if have_data == false
            request_params["AttachStdin"] = false
            request_params["Tty"] =  false
          else
            request_params["AttachStdin"] = true
            request_params["Tty"] =  false
          end
          request_params[ "AttachStdout"] =  true
          request_params[ "AttachStderr"] =  true
          request_params[ "DetachKeys"] =  "ctrl-p,ctrl-q"
          request_params[ "Cmd"] =  commands
      
          request = '/containers/'  + container.container_id.to_s + '/exec'
          r = post_request(request,  request_params)
          STDERR.puts('DOCKER EXEC ' + r.to_s + ': for :' + container.container_name + ': with :' + request_params.to_s)
          return r
   end
   
     
def format_commands(commands)
   commands = [commands] unless commands.is_a?(Array)
    commands
 end
 
end