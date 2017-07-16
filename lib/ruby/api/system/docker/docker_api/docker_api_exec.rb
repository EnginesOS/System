module DockerApiExec

  require_relative 'docker_utils.rb'
  class DockerHijackStreamHandler
    attr_accessor :result, :data, :i_stream, :o_stream, :stream
    def initialize(data, istream = nil, ostream = nil)
      @i_stream = istream
      @o_stream = ostream
      @data = data
      @result = {
        raw: '',
        stdout: '',
        stderr: ''
      }
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
      if @i_stream.nil? || @i_stream.closed? || @data.nil?
        false
      elsif @data.length > 0
        true
      else
        false
      end
    end

    def process_response()
      return_result = @result
      lambda do |chunk , c , t|
        if @o_stream.nil?
          DockerUtils.docker_stream_as_result(chunk, return_result)
         # return_result[:raw] = return_result[:raw] + chunk.to_s
        else
          r = DockerUtils.decode_from_docker_chunk(chunk, true)
          @o_stream.write(r[:stdout]) unless r.nil?
          return_result[:stderr] = return_result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end
  end

  class DockerStreamReader
    def is_hijack?
      false
    end
    attr_accessor :result, :stream

    def initialize(stream = nil)
      @o_stream = stream
      @result = {
        raw: '',
        stdout: '',
        stderr: ''
      }
    end

    def close
      @o_stream.close unless @o_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def process_response()
      return_result = @result
      lambda do |chunk , c , t|
        if @o_stream.nil?
          DockerUtils.docker_stream_as_result(chunk, return_result)
         # return_result[:raw] = return_result[:raw] + chunk.to_s
        else
          r = DockerUtils.decode_from_docker_chunk(chunk, true)
          @o_stream.write(r[:stdout]) unless r.nil?
          return_result[:stderr] = return_result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end

    def has_data?
      false
    end
  end

  def docker_exec(params)
    r = create_docker_exec(params) #container, commands, have_data)
    if r.is_a?(Hash)
      exec_id = r[:Id]
      request = '/exec/' + exec_id + '/start'
      request_params = {
        'Detach' => false,
        'Tty' => false,
        'User' => '',
        'Privileged' => false,
        'AttachStdout' => true,
        'AttachStderr' => true,
        'Container' => params[:container].container_name,
        'Cmd' => params[:command_line]
      }
      headers = {
        'Content-type' => 'application/json'
      }
      unless params.key?(:data) || params.key?(:data_stream)
        stream_reader = DockerStreamReader.new(params[:stream])
        result = {}
        r = post_stream_request(request, nil, stream_reader, headers, request_params.to_json)
        stream_reader.result[:result] = get_exec_result(exec_id)
        return stream_reader.result # DockerUtils.docker_stream_as_result(r, result)
      end
      request_params['AttachStdin'] = true
      stream_handler = DockerHijackStreamHandler.new(params[:data], params[:data_stream], params[:ostream])

      headers['Connection'] = 'Upgrade'
      headers['Upgrade'] = 'tcp'

      r = post_stream_request(request, nil, stream_handler, headers, request_params.to_json)
      stream_handler.result[:result] = get_exec_result(exec_id)
      stream_handler.result
    else
      r
    end
  
  end

  private

  def get_exec_result(exec_id)
    r = get_request('/exec/' + exec_id.to_s + '/json')
    r[:ExitCode]
  end

  def create_docker_exec(params) #container, commands, have_data)
    request_params = {
      'AttachStdout' => true,
      'AttachStderr' => true,
      'Tty' => false,
      'DetachKeys' => 'ctrl-p,ctrl-q',
      'Cmd' => format_commands(params[:command_line])
    }
    if params.key?(:data) || params.key?(:data_stream)
      request_params['AttachStdin'] = true
    else
      request_params['AttachStdin'] = false
    end
    request = '/containers/' + params[:container].container_id.to_s + '/exec'
     STDERR.puts('create_docker_exec ' + request_params.to_s + ' request  ' + request.to_s )
    post_request(request, request_params)
  end

  def format_commands(commands)
    commands = [commands] unless commands.is_a?(Array)
    commands
  end

end