module DockerApiExec

  require_relative 'docker_utils.rb'
  
  class DockerHijackStreamHandler
    attr_accessor :result, :data
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

  end
  
  class DockerStreamReader
    def is_hijack?
         false
       end
    attr_accessor :result
         def initialize()
          
           @result = {}
           @result[:raw] = ''
           @result[:stdout] = ''
           @result[:stderr] = ''
         end
   def process_response( )
     
     lambda do |chunk, remaining_bytes, total_bytes |  
       #@result[:raw] +=  chunk
       STDERR.puts('LABM ' + chunk.to_s )      
     end
     
  end  
    def has_data?
              return false 
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
    
    request_params["AttachStdout"] = true
    request_params["AttachStderr"] = true

      
    unless have_data == true
      result = {}
      stream_reader = DockerStreamReader.new
      post_stream_request(request, nil, stream_reader,  nil , nil )
      #      r = post_request(request,  request_params, false )
      return r if r.is_a?(EnginesError)
      return stream_reader.result # DockerUtils.docker_stream_as_result(r, result)
    end
  #  initheader = {'Transfer-Encoding' => 'chunked', 'content-type' => 'application/octet-stream' }
        request_params["User"] = ''
       request_params["Privileged"] = false
    request_params["AttachStdout"] = true
      request_params["AttachStderr"] = true 
        request_params["Container"] = container.container_name 
        request_params["Cmd"] = commands
    request_params["AttachStdin"] = true
    stream_handler = DockerHijackStreamHandler.new(data)
    headers = {}
    headers['Content-type'] = 'text/plain'
    headers['Connection'] = 'Upgrade'
    headers['Upgrade'] = 'tcp'
  
    post_stream_request(request, nil, stream_handler,  headers , request_params.to_json )
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