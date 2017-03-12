class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'
  require 'ffi_yajl'
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
    FFI_Yajl::Parser.new({:symbolize_keys => true})
  end

  def initialize
    #@response_parser =

    @connection = nil
  rescue StandardError => e
    log_exception(e)
  end

  require "base64"

  def get_registry_auth
    r = {"auth"=> "","email" => "","username" => '','password' => '' }
    Base64.encode64(r.to_json).gsub(/\n/, '')
  end

  def default_headers
    @default_headers ||= {'Content-Type' =>'application/json', 'Accept' => '*/*'}
  end

  def post_request(uri,  params = nil, expect_json = true , rheaders = nil, time_out = 60)
    rheaders = default_headers if rheaders.nil?
    params = params.to_json if rheaders['Content-Type'] == 'application/json' && ! params.nil?
    return handle_resp(
    connection.request(
    method: :post,:path => uri,
    read_timeout: time_out,
    headers: rheaders,
    body: params),
    expect_json)

  rescue StandardError => e
    log_exception(e,uri)
  end

  def connection

    @connection = Excon.new('unix:///', :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: true) if @connection.nil?
    SystemDebug.debug(SystemDebug.docker,' OPEN docker.sock connection ' + @connection.to_s)
    @connection
  end

  def reopen_connection
    @connection.reset
    SystemDebug.debug(SystemDebug.docker,' REOPEN doker.sock connection ')
    @connection = Excon.new('unix:///', :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: true)
    @connection
  rescue StandardError => e
    log_exception(e)
  end

  def stream_connection(stream_reader)
    excon_params = {
      debug_request: true,
      debug_response: true,
      persistent: false
    }

    if stream_reader.method(:is_hijack?).call == true
      excon_params[:hijack_block] = DockerUtils.process_request(stream_reader)
    else
      excon_params[:response_block] = stream_reader.process_response
    end

    excon_params[:socket] = '/var/run/docker.sock'
    Excon.new('unix:///', excon_params )
  end

  def post_stream_request(uri,options, stream_handler,  rheaders = nil, content = nil )
    rheaders = default_headers if rheaders.nil?
    content = '' if content.nil?
    sc = stream_connection(stream_handler)
    stream_handler.stream = sc

    if stream_handler.method(:has_data?).call == false
      if content.nil? # Dont to_s as may be tgz
        body = ''
      elsif rheaders['Content-Type'] == 'application/json'
        body = content.to_json
      else
        body = content
      end
      r  = sc.request(
      method: :post,
      read_timeout: 3600,
      query: options,
      path: uri,
      headers: rheaders,
      body: body
      )
      stream_handler.close
      return r
    else
      r  = sc.request(
      method: :post,
      read_timeout: 3600,
      query: options,
      path: uri,
      body: content,
      headers:  rheaders)
      stream_handler.close
      return r
    end
  rescue  Excon::Error::Socket => e
    STDERR.puts(' docker socket stream close ')
    stream_handler.close
  rescue StandardError => e
    log_exception(e)
  end

  def get_request(uri,  expect_json = true, rheaders = nil, timeout = 60)
    rheaders = default_headers if rheaders.nil?

    r = connection.request({method: :get,path: uri,read_timeout: timeout,headers: rheaders})
    #  STDERR.puts(' docker rget' + r.to_s)
    return handle_resp(r,expect_json) unless headers.nil?

    handle_resp(connection.request(:method => :get,
    :path => uri),
    expect_json
    )
  rescue  Excon::Error::Socket => e
    STDERR.puts(' docker socket close ')
    reopen_connection
    retry
  end

  def delete_request(uri)
    handle_resp(connection.request(method: :delete,
    path: uri),
    false
    )
  rescue  Excon::Error::Socket => e
    STDERR.puts('docker socket close ')
    reopen_connection
    retry
  end

  private

  def handle_resp(resp, expect_json)
    STDERR.puts(" RESPOSE " + resp.status.to_s + " : " + resp.body  ) if resp.status  >= 400
    return log_error_mesg("error:" + resp.status.to_s,resp.body ).to_json  if resp.status  >= 400
    return true if resp.status  == 204 # nodata but all good happens on del
    return log_error_mesg("Un exepect response from docker", resp, resp.body, resp.headers.to_s )   unless resp.status  == 200 ||  resp.status  == 201
    return resp.body unless expect_json == true
    #only want first so return n first
    # hash =  response_parser.parse(resp.body) #do |hash |
    hash =  SystemUtils.deal_with_jason(JSON.parse(resp.body, create_additons: true ))
    # STDERR.puts(" RESPOSE " + hash.to_s  )
    return hash
    #  @hashes.push(hash)
    #   return hash
    # end
    #  return @hashes[0]
  rescue StandardError => e
    log_error_mesg("Un exepect response content " +   resp.to_s)
    return log_exception(e).json if expect_json == true
    log_exception(e).to_s
  end

end