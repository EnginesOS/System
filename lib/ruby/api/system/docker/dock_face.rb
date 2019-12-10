require 'net_x/http_unix'
require 'socket'
require 'yajl'
require 'rubygems'
require 'excon'
require 'yajl/json_gem'

class DockFace < ErrorsApi
  class << self
    def instance
      @@instance ||= self.new
    end
  end

  require '/opt/engines/lib/ruby/exceptions/docker_exception.rb'

  require_relative 'excon_hijack.rb'
  Excon.defaults[:middlewares].unshift Excon::Middleware::Hijack

  require_relative 'dock_face_errors.rb'
  include EnginesDockFaceErrors
  require_relative 'dock_face_exec.rb'
  include DockFaceExec

  require_relative 'dock_face_container_actions.rb'
  include DockFaceContainerActions
  require_relative 'dock_face_container_status.rb'
  include DockFaceContainerStatus

  require_relative 'dock_face_images.rb'
  include DockFaceImages

  require_relative 'dock_face_container_ops.rb'
  include DockFaceContainerOps

  require_relative 'dock_face_builder.rb'
  include DockFaceBuilder

  require_relative 'docker_net.rb'
  include DockerNet

  require_relative 'docker_http.rb'
  include DockerHttp

  def response_parser
    @parser ||= FFI_Yajl::Parser.new({:symbolize_keys => true})
  end

  def initialize
    @connection = nil
    @dock_face_mutex = Mutex.new
  end

  require "base64"

  def registry_root_auth
    r = {"auth"=> "", "email" => "", "username" => '' ,'password' => '' }
    Base64.encode64(r.to_json).gsub(/\n/, '')
  end

end
