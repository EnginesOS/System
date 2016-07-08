module DockerApiExec

  require_relative 'docker_utils.rb'
  
  class DockerStreamHandler
    attr_accessor :result
      def initialize(data, result)
        @data = data
        @result = result
        @result[:raw] = ''
        @result[:stdout] = ''
          @result[:stderr] = ''
      end
    
     def is_hijack?
       false
     end
          def has_data?
            return false if @data.nil?
            return true unless @data.length == 0 
            return false
          end
          
      def process_response(chunk , c , t)
        DockerUtils.docker_stream_as_result(chunk, @result)
      @result[:raw] = @result[:raw] + chunk
  STDERR.puts( ' parse build res  ' + chunk.to_s )
     rescue StandardError =>e
          STDERR.puts( ' parse build res EOROROROROR ' + chunk.to_s + ' : ' +  e.to_s)
                      return
  
      end
    def process_request(*args)
         
           return nil if @data.length == 0
           if @data.length < Excon.defaults[:chunk_size]
             STDERR.puts('PROCESS REQUEST with single chunk')
             r = @data
             @data = ''
             return r
           else
             return @data.slice!(0,Excon.defaults[:chunk_size])
           end
       
      rescue StandardError => e
        STDERR.puts('PROCESS REQUEST got ' + e.to_s)
        return nil
         end
    end
    
  def docker_exec(container, commands, log_error = true, data=nil)
    have_data = false
    have_data = true unless data.nil?
    
      r = create_docker_exec(container, commands, have_data)
    
      return r unless r.is_a?(Hash)
    result = {}
      exec_id = r['Id']
      request_params = {}
      request_params["Detach"] = false
      request_params["Tty"] = true
      request = '/exec/' + exec_id + '/start'
    unless have_data == true
      r = post_request(request,  request_params, false )
      return r if r.is_a?(EnginesError)
      return DockerUtils.docker_stream_as_result(r, result)
    end
    initheader = {'Transfer-Encoding' => 'chunked', 'content-type' => 'application/octet-stream' }

    stream_handler = DockerStreamHandler.new(data, result)
    post_stream_request(request,nil, stream_handler,  initheader  )
    result
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
            request_params["Tty"] =  true
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