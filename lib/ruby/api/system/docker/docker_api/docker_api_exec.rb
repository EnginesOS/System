module DockerApiExec

  require_relative 'docker_utils.rb'
  class DockerHijackStreamHandler
    attr_accessor :result, :data, :i_stream, :o_stream, :stream
    def initialize(data, istream=nil, ostream=nil)
      @i_stream = istream
      @o_stream = ostream
      @data = data
      @result = {}
      @result[:raw] = ''
      @result[:stdout] = ''
      @result[:stderr] = ''
    end

    def close
      @o_stream.close unless @o_stream.nil?
      @i_stream.close unless @i_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def is_hijack?
      true
    end

    def has_data?
      unless  @i_stream.nil?
        return true unless @i_stream.closed?
      end
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
    attr_accessor :result, :stream

    def initialize(stream=nil )
      @o_stream = stream
      @result = {}
      @result[:raw] = ''
      @result[:stdout] = ''
      @result[:stderr] = ''
    end

    def close
      @o_stream.close unless @o_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def process_response()
      return_result = @result
      lambda do |chunk , c , t|
        if  @o_stream.nil?
          DockerUtils.docker_stream_as_result(chunk, return_result)
          return_result[:raw] = return_result[:raw] + chunk.to_s
        else
          r = DockerUtils.decode_from_docker_chunk(chunk)
          @o_stream.write(r[:stdout]) unless r.nil?
          return_result[:stderr] =  return_result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end

    def has_data?
       false
    end
  end

  def docker_exec(params)
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
    headers['Content-type'] = 'application/json'
    unless params.key?(:data) || params.key?(:data_stream)
      result = {}
      stream_reader = DockerStreamReader.new(params[:stream])
      r =  post_stream_request(request, nil, stream_reader,  headers ,  request_params.to_json  )
      return r if r.is_a?(EnginesError)
      stream_reader.result[:result] = get_exec_result(exec_id)
      return stream_reader.result # DockerUtils.docker_stream_as_result(r, result)
    end

    request_params["AttachStdin"] = true
    stream_handler = DockerHijackStreamHandler.new(params[:data],params[:data_stream], params[:ostream])

    headers['Connection'] = 'Upgrade'
    headers['Upgrade'] = 'tcp'

    r =   post_stream_request(request, nil, stream_handler,  headers , request_params.to_json )
    return r if r.is_a?(EnginesError)
    stream_handler.result[:result] = get_exec_result(exec_id)
    stream_handler.result

  rescue StandardError => e
    STDERR.puts('DOCKER EXECep  ' + params.to_s + ': with :' + request_params.to_s)
    log_exception(e)
  end

  private

  def  get_exec_result(exec_id)
    r  = get_request('/exec/' + exec_id.to_s + '/json')
    return -1 if r.is_a?(EnginesError)
    r[:ExitCode]
  end

  def create_docker_exec(params) #container, commands, have_data)

    request_params = {}
    if params.key?(:data) || params.key?(:data_stream)
      request_params["AttachStdin"] = true
      request_params["Tty"] =  false
    else
      request_params["AttachStdin"] = false
      request_params["Tty"] =  false
    end
    request_params[ "AttachStdout"] =  true
    request_params[ "AttachStderr"] =  true
    request_params[ "DetachKeys"] =  "ctrl-p,ctrl-q"
    request_params[ "Cmd"] =   format_commands(params[:command_line])

    request = '/containers/'  + params[:container].container_id.to_s + '/exec'

     post_request(request,  request_params)
    
  end

  def format_commands(commands)
    commands = [commands] unless commands.is_a?(Array)
    commands
  end

end