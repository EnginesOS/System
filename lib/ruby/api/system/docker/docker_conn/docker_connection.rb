class DockerConnection < ErrorsApi

  require 'net_x/http_unix'
  require 'socket'
  require 'yajl'
  require 'rubygems'
  require 'excon'

  require_relative 'hijack.rb'
  Excon.defaults[:middlewares].unshift Excon::Middleware::Hijack

  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors
  require_relative 'docker_api_exec.rb'
  include DockerApiExec

  require_relative 'docker_api_container_actions.rb'
  include DockerApiContainerActions
  require_relative 'docker_api_container_status.rb'
  include DockerApiContainerStatus

  require_relative 'docker_api_images.rb'
  include DockerApiImages

  require_relative 'docker_api_container_ops.rb'
  include DockerApiContainerOps

  require_relative 'docker_api_builder.rb'
  include DockerApiBuilder

  def response_parser
    @parser ||= FFI_Yajl::Parser.new({:symbolize_keys => true})
  end

  def initialize
    @connection = nil
    @docker_api_mutex = Mutex.new
  end

  require "base64"

  def registry_root_auth
    r = {"auth"=> "", "email" => "", "username" => '' ,'password' => '' }
    Base64.encode64(r.to_json).gsub(/\n/, '')
  end

  def default_headers
    @default_headers ||= {'Content-Type' =>'application/json', 'Accept' => '*/*'}
  end


           
  def post_request(p)
    fillin_params(p)
    p[:params] = p[:params].to_json if p[:headers]['Content-Type'] == 'application/json' && ! p[:params].nil?

    @docker_api_mutex.synchronize {
      handle_resp(
      connection.request(
      method: :post,
      path: p[:uri],
      read_timeout: p[:timeout],
      headers: p[:headers],
      body: p[:params]),
      p[:expect_json])}
  end

  def connection
    #  @connection =
    Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: false, #true  #,
    thread_safe_sockets: true
    )  #if @connection.nil?
    # @connection
  end

  def reopen_connection
    @connection.reset unless @connection.nil?
    #  SystemDebug.debug(SystemDebug.docker,' REOPEN doker.sock connection ')
    @connection = Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: true,
    thread_safe_sockets: true)
    @connection
  end

  def stream_connection(stream_reader)
    excon_params = {
      debug_request: true,
      debug_response: true,
      persistent: false,
      thread_safe_sockets: true
    }

    if stream_reader.method(:is_hijack?).call == true
      excon_params[:hijack_block] = DockerUtils.process_request(stream_reader)
    else
      excon_params[:response_block] = stream_reader.process_response
    end
    excon_params[:socket] = '/var/run/docker.sock'
    Excon.new('unix:///', excon_params)
  end

  def post_stream_request(p) 
    p[:headers] = default_headers if p[:headers]
    p[:content] = '' if p[:content].nil?
    sc = stream_connection(p[:stream_handler])

    if p[:stream_handler].method(:has_data?).call == false
      if  p[:headers]['Content-Type'] == 'application/json'
        body = p[:content].to_json
      else
        body = p[:content]
      end
      r = sc.request(
      method: :post,
      read_timeout: 3600,
      path: p[:uri] + '?' + p[:options].to_s,
      headers: p[:headers],
      body: body
      )
      p[:stream_handler].close
    else
      r = sc.request(
      method: :post,
      read_timeout: 3600,
      path: p[:uri] + '?' + p[:options].to_s,
      headers: p[:headers],
      body: p[:content]
      )
      p[:stream_handler].close
    end
    sc.reset unless sc.nil?
    r

  rescue Excon::Error::Socket
    STDERR.puts('Excon docker socket stream close ')
      p[:stream_handler].close unless p[:stream_handler].nil?
    sc.reset unless sc.nil?
    r
  rescue  Excon::Error::Timeout
    STDERR.puts('Excon docker socket timeout ')
      p[:stream_handler].close unless p[:stream_handler].nil?
    sc.reset unless sc.nil?
    nil
  end

  def request_params(params)
    @request_params = params
  end

  def get_request(p)
    fillin_params(p)

    @docker_api_mutex.synchronize {
      handle_resp(
      connection.request(
      request_params(
      {
        method: :get,
        path: p[:uri],
        read_timeout: p[:timeout],
        headers: p[:headers] 
      }
      )
      ), p[:expect_json])
    }
  rescue  Excon::Error::Socket
    STDERR.puts(' docker socket close ')
    nil
  rescue  Excon::Error::Timeout
    STDERR.puts(' docker socket timeout ')
    nil
  end

  def delete_request(uri)
    @docker_api_mutex.synchronize {
      handle_resp(connection.request(request_params({method: :delete,
        path: uri})),
      false
      ) }
  rescue  Excon::Error::Socket
    STDERR.puts('docker socket close ')
  rescue  Excon::Error::Timeout
    STDERR.puts(' docker socket timeout ')
    nil
  end

  private

  def fillin_params(p)
    p[:headers] = default_headers if p[:headers].nil?
       p[:expect_json] = true unless p.key?(:expect_json) 
       p[:timeout] = 180 unless p.key?(:read_timeout)
  end
  
  def handle_resp(resp, expect_json)
    raise DockerException.new({params: @request_param, status: 500}) if resp.nil?
    #SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE CODE' + resp.status.to_s )
  #  if resp.status > 399
      #  SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE CODE' + resp.status.to_s )
      # SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE Body' + resp.body.to_s )
      #SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE' + resp.to_s ) unless resp.status == 404
   # end
    raise DockerException.new({params: @request_params, status: resp.status, body: resp.body}) if resp.status >= 400
    if resp.status == 204 # nodata but all good happens on del
      true
    else
      log_error_mesg("Un expected response from docker", resp, resp.body, resp.headers.to_s) unless resp.status == 200 || resp.status == 201
      if expect_json == true
        response_parser.parse(resp.body)
      else
        resp.body
      end
    end
  end

end