module DockerApiExec

  require_relative 'docker_utils.rb'
  class DockerHijackStreamHandler
    attr_accessor :result, :data, :i_stream, :o_stream
    def initialize(data, istream=nil, ostream=nil)
      @i_stream = istream
      @o_stream = ostream
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
        if  @o_stream.nil?
          DockerUtils.docker_stream_as_result(chunk, return_result)
          return_result[:raw] = return_result[:raw] + chunk.to_s
          STDERR.puts( ' parse exec_hj res  ' + chunk.length.to_s )
        else
          r = DockerUtils.decode_from_docker_chunk(chunk)
          @o_stream.write(r[:stdout]) unless r.nil?
          return_result[:stderr] =  return_result[:stderr].to_s + r[:stderr].to_s
            
        end
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

    def initialize(stream=nil )
      @o_stream = stream
      @result = {}
      @result[:raw] = ''
      @result[:stdout] = ''
      @result[:stderr] = ''
    end

    def process_response()
      return_result = @result
      lambda do |chunk , c , t|
        if  @o_stream.nil?
          DockerUtils.docker_stream_as_result(chunk, return_result)
          return_result[:raw] = return_result[:raw] + chunk.to_s
          STDERR.puts( 'exec parse process  res  ' + chunk.length.to_s )
        else
          r = DockerUtils.decode_from_docker_chunk(chunk)
          @o_stream.write(r[:stdout]) unless r.nil?
          return_result[:stderr] =  return_result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end

    def has_data?
      return false
    end
  end

  def docker_exec(params) #container, commands, log_error = true, data=nil)
    #have_data = false
    #have_data = true unless data.nil?

    r = create_docker_exec(params) #container, commands, have_data)

    return r unless r.is_a?(Hash)

    exec_id = r[:Id]
    request_params = {}
    request_params["Detach"] = false
    request_params["Tty"] = false
    request = '/exec/' + exec_id + '/start'
    request_params["User"] = ''
    request_params["Privileged"] = false
    request_params["AttachStdout"] = true
    request_params["AttachStderr"] = true
    request_params["Container"] = params[:container].container_name
    request_params["Cmd"] = params[:command_line]

    headers = {}
    headers['Content-type'] = 'text/plain'

    unless params.key?(:data)
      result = {}
      stream_reader = DockerStreamReader.new(params[:stream])
      r =  post_stream_request(request, nil, stream_reader,  headers ,  request_params.to_json  )
      return r if r.is_a?(EnginesError)
      stream_reader.result[:result] = get_exec_result(exec_id)
      return stream_reader.result # DockerUtils.docker_stream_as_result(r, result)
    end
    #  initheader = {'Transfer-Encoding' => 'chunked', 'content-type' => 'application/octet-stream' }

    request_params["AttachStdin"] = true
    stream_handler = DockerHijackStreamHandler.new(params[:data],params[:istream], params[:ostream])

    headers['Connection'] = 'Upgrade'
    headers['Upgrade'] = 'tcp'

   r =  post_stream_request(request, nil, stream_handler,  headers , request_params.to_json )
    STDERR.puts('EXEC RES ' + stream_handler.result.to_s + ' with r ' + r.to_s)
    stream_handler.result[:result] = get_exec_result(exec_id)
    stream_handler.result

  rescue StandardError => e
    STDERR.puts('DOCKER EXECep  ' + params[:container].container_name + ': with :' + request_params.to_s)
    log_exception(e)
  end


  private
 
  def  get_exec_result(exec_id)        
    r  = get_request('/exec/' + exec_id.to_s + '/json')
    return -1 if r.is_a?(EnginesError)
    r[:ExitCode]    
  end

  def create_docker_exec(params) #container, commands, have_data)
    commands = format_commands(params[:command_line])

    request_params = {}
    if params.key?(:data)
      request_params["AttachStdin"] = true
      request_params["Tty"] =  false
    else
      request_params["AttachStdin"] = false
      request_params["Tty"] =  false
    end
    request_params[ "AttachStdout"] =  true
    request_params[ "AttachStderr"] =  true
    request_params[ "DetachKeys"] =  "ctrl-p,ctrl-q"
    request_params[ "Cmd"] =  commands

    request = '/containers/'  + params[:container].container_id.to_s + '/exec'
    r = post_request(request,  request_params)
    STDERR.puts('DOCKER EXEC ' + r.to_s + ': for :' + params[:container].container_name + ': with :' + request_params.to_s)
    return r
  end

  def format_commands(commands)
    commands = [commands] unless commands.is_a?(Array)
    commands
  end

end