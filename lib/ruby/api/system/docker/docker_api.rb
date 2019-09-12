class DockerApi < ErrorsApi

  require 'net_x/http_unix'
  require 'socket'
  require 'yajl'
  require 'rubygems'
  require 'excon'
  
  require '/opt/engines/lib/ruby/exceptions/docker_exception.rb'
  
  require_relative 'hijack/excon_hijack.rb'
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
  
  require_relative 'docker_net.rb'
  include DockerNet
  
  require_relative 'docker_http.rb'
  include DockerHttp
  
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

end