module DockerApiExec

  require_relative 'docker_utils.rb'
  class DockerHijackStreamHandler
    attr_accessor :result, :data, :i_stream, :out_stream, :stream
    def initialize(data, istream = nil, out_stream = nil)
      @i_stream = istream
      @out_stream = out_stream
      @data = data
      @result = {
        raw: '',
        stdout: '',
        stderr: ''
      }
    end

    def close
      @out_stream.close unless @out_stream.nil?
      @i_stream.close unless @i_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def is_hijack?
      true
    end

    def has_data?
      if (@i_stream.nil? || @i_stream.closed? ) && @data.nil?
        STDERR.puts("\n HAS NO DTAT ")
        false
      elsif !@data.nil? && @data.length > 0
        STDERR.puts(' HAS STR DTAT ')
        true
      elsif ! @i_stream.nil?
        true
      else
        false
      end
      #    if @data.length > 0
      #          STDERR.puts(' HAS DTAT ')
      #                true
      #        elsif @i_stream.nil? || @i_stream.closed?
      #          false
      #        else
      #          true
      #        end
    end

    #    def process_response()
    #
    #      lambda do |chunk , c , t|
    #        STDERR.puts('a hijack')
    #        if @out_stream.nil?
    #          #   STDERR.puts('stream results')
    #          STDERR.puts(' hj 1 a chunker')
    #          r = DockerUtils.decode_from_docker_chunk(chunk, true)
    #          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
    #          @result[:stdout] = @result[:stdout].to_s + r[:stdout].to_s
    #          # return_result[:raw] = return_result[:raw] + chunk.to_s
    #        else
    #          r = DockerUtils.decode_from_docker_chunk(chunk, true)
    #          STDERR.puts('hj 1 a stream')
    #          @out_stream.write(r[:stdout]) unless r.nil?
    #          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
    #        end
    #      end
    #    end
  end

  class DockerStreamReader
    def is_hijack?
      false
    end
    attr_accessor :result, :stream

    def initialize(stream = nil)
      @out_stream = stream
      @result = {
        raw: '',
        stdout: '',
        stderr: ''
      }
    end

    def close
      @out_stream.close unless @out_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def process_response()
      lambda do |chunk , c , t|
        if @out_stream.nil?
          STDERR.puts(' SR a chunk')
          r = DockerUtils.decode_from_docker_chunk(chunk, true)
          next if r.nil?
          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
          @result[:stdout] = @result[:stdout].to_s + r[:stdout].to_s
          # return_result[:raw] = return_result[:raw] + chunk.to_s
        else
          STDERR.puts(' SR a stream')
          r = DockerUtils.decode_from_docker_chunk(chunk, true, @out_stream)
          next if r.nil?
          # @out_stream.write(r[:stdout])
          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
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
      STDERR.puts(r.to_s)
      exec_id = r[:Id]
      request = '/exec/' + exec_id + '/start'
      request_params = {
        'Detach' => false,
        'Tty' => false,
      }

      headers = {
        'Content-type' => 'application/json'
      }

      SystemDebug.debug(SystemDebug.docker,'docker_exec ' + request_params.to_s + ' request  ' + request.to_s )
      unless params.key?(:data_stream) || params.key?(:data)
        stream_reader = DockerStreamReader.new(params[:stream])
        STDERR.puts("\n\nSTREA " + request_params.to_s )
        r = post_stream_request(request, nil, stream_reader, headers, request_params.to_json)
        stream_reader.result[:result] = get_exec_result(exec_id)
        STDERR.puts("\n\nSTREA resul " + stream_reader.result.to_s)
        r = stream_reader.result
      else
        stream_handler = DockerHijackStreamHandler.new(params[:data], params[:data_stream], params[:stdout_stream])
        #   headers['Connection'] = 'Upgrade',
        #    headers['Upgrade'] = 'tcp'
        STDERR.puts("\n\Hijack " + request_params.to_s )
        r = post_stream_request(request, nil, stream_handler, headers, request_params.to_json)
        stream_handler.result[:result] = get_exec_result(exec_id)
        STDERR.puts("\n\Hijack resul " + stream_handler.result.to_s)
        r = stream_handler.result

        #unless params.key?(:data_stream) ||params.key?(:data)

        # DockerUtils.docker_stream_as_result(r, result)
      end

    end
    r
  end

  private

  def get_exec_result(exec_id)
    r = get_request('/exec/' + exec_id.to_s + '/json')
    STDERR.puts(r.to_s)
    r[:ExitCode]
  end

  def create_docker_exec(params) #container, commands, have_data)
    request_params = {
      'AttachStdout' => true,
      'AttachStderr' => true,
      'Tty' => false,
      'Env' => exec_env(params),
      'DetachKeys' => 'ctrl-p,ctrl-q',
      'Cmd' => format_commands(params[:command_line])
    }
    params.delete(:data) if params.key?(:data) && params[:data].nil?
    if params.key?(:data) || params.key?(:data_stream)
      request_params['AttachStdin'] = true
    else
      request_params['AttachStdin'] = false
    end
    request = '/containers/' + params[:container].container_id.to_s + '/exec'
    SystemDebug.debug(SystemDebug.docker,'create_docker_exec ' + request_params.to_s + ' request  ' + request.to_s )
    post_request(request, request_params)
  end

  def format_commands(commands)
    STDERR.puts('Commands is an array') if commands.is_a?(Array)
    commands = [commands] unless commands.is_a?(Array)
    commands
  end

  def service_variables_to_env(service_hash)
    r = service_hash.dup
    if r.is_a?(Hash) && r.key?(:variables)
      r.merge!(service_hash[:variables])
      r.delete(:variables)
      r
    else
      nil
    end
    
  end

  def exec_env(params)
    envs = []
    unless params.nil?
      if params[:service_variables].is_a?(Hash)
       p =  service_variables_to_env(params[:service_variables])
        p.each_pair do |k,v|
          envs.push(k.to_s + '=' + v.to_s)
        end
      end
      if params[:action_params].is_a?(Hash)
      #  action_params_to_env!(params[:action_params])
        params[:action_params].each_pair do |k,v|
          envs.push(k.to_s + '=' + v.to_s)
        end
      end
      if params[:configuration].is_a?(Hash)
        params[:configuration].each_pair do |k,v|
          envs.push(k.to_s + '=' + v.to_s)
        end
      end
    end
    envs
  end

end