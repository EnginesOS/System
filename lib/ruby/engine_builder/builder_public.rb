require 'securerandom' 

class BuilderPublic
  def initialize(builder)
    @builder = builder
  end

  def engine_name
    @builder.engine_name
  end

  def domain_name
    @builder.domain_name
  end

  def fqdn
    @builder.hostname + '.' + @builder.domain_name
  end

  def hostname
    @builder.hostname
  end

  def http_protocol
    case @build_params[:http_protocol]
    when 'HTTPS and HTTP'
        @build_params[:http_protocol] = 'http_https'
    when 'HTTPS only'
        @build_params[:http_protocol] = 'https'
    when 'HTTP'
        @build_params[:http_protocol] = 'http'
  end
    return @build_params
  end

  def repository
    @builder.repo_name
  end

  def web_port
    @builder.web_port
  end

  def build_name
    @builder.build_name
  end

  def runtime
    @builder.runtime
  end

  def set_environments
    @builder.set_environments
  end

  def engine_environment
    @builder.engine_environment
  end

  def blueprint
    @builder.blueprint
  end

  def data_gid
    @builder.data_gid
  end

  def memory
    @builder.memory
  end
end
