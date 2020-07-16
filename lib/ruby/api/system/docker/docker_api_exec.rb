module DockerApiExec
  require_relative 'decoder/docker_decoder.rb'
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
    #  @i_stream.close unless @i_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def is_hijack?
      true
    end

    def has_data?
      if (@i_stream.nil?  && @data.nil? ) #|| @i_stream.closed? ) && @data.nil?
        false
      elsif !@data.nil? && @data.length > 0
        true
      elsif ! @i_stream.nil?
        true
      else
        false
      end
    end

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
      @decoder = DockerDecoder.new({ result:  @result})
    end

    def close
      @out_stream.close unless @out_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def process_response()
      lambda do |chunk , c , t|
        if @out_stream.nil?
          r = @decoder.decode_from_docker_chunk({chunk: chunk, binary: true, result: @result})
          next if r.nil?
          #@result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
          #@result[:stdout] = @result[:stdout].to_s + r[:stdout].to_s
        else
          r = @decoder.decode_from_docker_chunk({chunk: chunk, binary: true, stream: @out_stream, result: @result})
          next if r.nil?
          #  @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end

    def has_data?
      false
    end
  end

  def docker_exec(p)
    params = p.dup
    params[:timeout] = 30 if params[:timeout].nil?

    r = create_docker_exec(params)
    if r.is_a?(Hash)
      params[:exec_id] = r[:Id]
      params[:request] = "/exec/#{params[:exec_id]}/start"
      unless params[:background].is_a?(TrueClass)
        Timeout.timeout(params[:timeout] + 1) do # wait 1 sec longer incase another timeout in caller
          start_exec(params)
        end
      else
        start_exec(params)
      end
    end
  rescue Timeout::Error
    signal_exec({exec_id: params[:exec_id], signal: 'TERM', container: params[:container], background: true})
    r = {}
    r[:result] = -1;
    r[:stderr] = "Timeout on Docker exec:#{params[:command_line]}:#{params[:container].container_name}"
    STDERR.puts(' Timeout ' + r.to_s)
    raise EnginesException.new(warning_hash("Timeout on Docker exec passed #{params[:timeout]} secs", r))
  end

  private

  def start_exec(params)
    params[:background] = false unless params.key?(:background)
    request_params = {
      'Detach' => params[:background] ,
      'Tty' => false,
    }
    headers = {
      'Content-type' => 'application/json'
    }
    unless params.key?(:stdin_stream) || params.key?(:data)
      stream_handler = DockerStreamReader.new(params[:stdout_stream])
    else
      stream_handler = DockerHijackStreamHandler.new(params[:data], params[:stdin_stream], params[:stdout_stream])
    end
    STDERR.puts( {uri: params[:request],
      stream_handler: stream_handler,
      headers: headers,
      content: request_params.to_json}.to_s)
    post_stream_request({uri: params[:request],
      stream_handler: stream_handler,
      headers: headers,
      content: request_params.to_json})
    stream_handler.result[:result] = get_exec_result(params[:exec_id])
    stream_handler.result
  end

  def resolve_pid_to_container_id(pid)
    s = get_pid_status(pid)
    unless s.is_a?(FalseClass)
      # STDERR.puts('Status ' + s.to_s)
      r = s[/NSpid:.*\n/]
      unless r.nil?
        r = r.split(' ')
        r[2]
      else
        -1
      end
    end
  end

  def get_pid_status(pid)
    if File.exists?("/host/proc/#{pid}/status")
      begin
        f = File.open("/host/proc/#{pid}/status")
        f.read
      ensure
        f.close
      end
    else
      STDERR.puts("NO such File:/host/proc/#{pid}/status")
      false
    end
  end

  def signal_exec(params)
    r = get_exec_details(params[:exec_id])
   # STDERR.puts(' Timeout signal_exec ' + params[:exec_id].to_s + ':' + r.to_s )
    pid = resolve_pid_to_container_id(r[:Pid])
    params[:command_line] = "kill -#{params[:signal]} #{pid}"
    params[:timeout] = 1 #note actually 2
    #STDERR.puts('KILL ' + params[:signal].to_s + ' container pi ' + pid.to_s + ':system:' + r[:Pid].to_s)
    docker_exec(params) unless pid == -1
  end

  def get_exec_details(exec_id)
    get_request({uri: "/exec/#{exec_id}/json"})
  end

  def get_exec_result(exec_id)
    r = get_exec_details(exec_id)
    # STDERR.puts(' exec results ' + r.to_s)
    if(r[:Running].is_a?(TrueClass))
      STDERR.puts('WARNING EXEC STILL RUNNING:' + r.to_s)
    end
    r[:ExitCode]
  end

  def create_docker_exec(params)
    request_params = {
      'AttachStdout' => true,
      'AttachStderr' => true,
      'Tty' => false,
      'Env' => exec_env(params),
      'DetachKeys' => 'ctrl-p,ctrl-q',
      'Cmd' => format_commands(params[:command_line])
    }
    params.delete(:data) if params.key?(:data) && params[:data].nil?
    params.delete(:stdin_stream) if params.key?(:stdin_stream) && params[:stdin_stream].nil?
    if params.key?(:data) || params.key?(:stdin_stream)
      request_params['AttachStdin'] = true
    else
      request_params['AttachStdin'] = false
    end
    STDERR.puts({uri: '/containers/' + params[:container].container_id.to_s + '/exec' , params: request_params}.to_s)
    post({uri: "/containers/#{params[:container].container_id}/exec" , params: request_params})
  end

  def format_commands(commands)
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
          envs.push("#{k}=#{v}")
        end
      end
      if params[:action_params].is_a?(Hash)
        params[:action_params].each_pair do |k,v|
          envs.push("#{k}=#{v}")
        end
      end
      if params[:configuration].is_a?(Hash)
        params[:configuration].each_pair do |k,v|
          envs.push("#{k}=#{v}")
        end
      end
    end
    envs
  end

end