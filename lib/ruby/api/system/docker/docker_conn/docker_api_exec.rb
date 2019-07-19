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
        #    STDERR.puts("\n HAS NO DTAT ")
        false
      elsif !@data.nil? && @data.length > 0
        #  STDERR.puts(' HAS STR DTAT ')
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
    end

    def close
      @out_stream.close unless @out_stream.nil?
      @stream.reset unless @stream.nil?
    end

    def process_response()
      lambda do |chunk , c , t|
        if @out_stream.nil?
          #  STDERR.puts(' SR a chunk')
          r = DockerUtils.decode_from_docker_chunk(chunk, true)
          next if r.nil?
          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
          @result[:stdout] = @result[:stdout].to_s + r[:stdout].to_s
        else
          #   STDERR.puts(' SR a stream')
          r = DockerUtils.decode_from_docker_chunk(chunk, true, @out_stream)
          next if r.nil?
          @result[:stderr] = @result[:stderr].to_s + r[:stderr].to_s
        end
      end
    end

    def has_data?
      false
    end
  end

  def docker_exec(params)
    r = create_docker_exec(params)
    if r.is_a?(Hash)
      exec_id = r[:Id]
      request = '/exec/' + exec_id + '/start'
      request_params = {
        'Detach' => params[:background] ,
        'Tty' => false,
      }
      STDERR.puts('Exec Starting ' + params.keys.to_s)
      headers = {
        'Content-type' => 'application/json'
      }
      Timeout.timeout(params[:timeout] + 2) do # wait 1 sec longer incase another timeout prior
        unless params.key?(:stdin_stream) || params.key?(:data)
          stream_reader = DockerStreamReader.new(params[:stdout_stream])
          r = post_stream_request(request, nil, stream_reader, headers, request_params.to_json)
          stream_reader.result[:result] = get_exec_result(exec_id)
          r = stream_reader.result
        else
          stream_handler = DockerHijackStreamHandler.new(params[:data], params[:stdin_stream], params[:stdout_stream])
          r = post_stream_request(request, nil, stream_handler, headers, request_params.to_json)
          stream_handler.result[:result] = get_exec_result(exec_id)
          r = stream_handler.result
        end
      end
    end
    r
  rescue Timeout::Error
    #FIX ME and kill process
    # 
     signal_exec({exec_id: exec_id, signal: 'TERM', container: params[:container]})
    #
    r = {}
    r[:result] = -1;
    r[:stderr] = 'Timeout on Docker exec :' + params[:command_line].to_s + ':' + params[:container].container_name.to_s
    STDERR.puts(' Timeout ' + r.to_s)
    raise EnginesException.new(warning_hash('Timeout on Docker exec', r))
  end

  private
def resolve_pid_to_container_id(pid)
  s = get_pid_status
  unless s.is_a?(FalseClass)
    STDERR.puts('Status ' + s.to_s)
    r = s[/NSpid:.*\n/]
    unless r.nil?
      r = r.split[' ']
      r[2] 
    else
      -1  
    end
  end
end

def get_pid_status(pid)
  if File.exists?('/host/sys/' + pid.to_s + '/status')
    begin
      f = File.open('/host/sys/' + pid.to_s + '/status')
      f.read
    ensure
      f.close
    end
  else
    false
  end
end
  def signal_exec(params)
    r = get_exec_details(params[:exec_id])
    STDERR.puts(' Timeout signal_exec ' + params[:exec_id].to_s + ':' + r.to_s )
      pid = resolve_pid_to_container_id(r[:Pid])
     params[:command_line] = 'kill -' +  params[:signal] + ' ' + pid.to_s
    params[:timeout] = 0 #note actually 2
    docker_exec(params) unless pid == -1
  end
  
  def get_exec_details(exec_id)
     get_request('/exec/' + exec_id.to_s + '/json')
  end
  
  def get_exec_result(exec_id)
    r = get_exec_details(exec_id)
    if(r[:Running].is_a?(TrueClass))
      STDERR.puts('WARNING EXEC STILL RUNNING:' + r.to_s)
    end
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
    if params.key?(:data) || params.key?(:stdin_stream)
      request_params['AttachStdin'] = true
    else
      request_params['AttachStdin'] = false
    end
    request = '/containers/' + params[:container].container_id.to_s + '/exec'
    SystemDebug.debug(SystemDebug.docker,'create_docker_exec ' + request_params.to_s + ' request  ' + request.to_s )
    post_request(request, request_params)
  end

  def format_commands(commands)
    #  STDERR.puts('Commands is an array') if commands.is_a?(Array)
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