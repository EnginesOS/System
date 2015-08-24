require 'securerandom' 

# @framework = framework
#   @runtime = runtime
#   @databases = databases
#   @setState = setState
#   @port = port
#   @repo = repo
#   @last_error = last_error
#   @memory = mem
#   @container_name = name
#   @host_name = host
#   @domain_name = domain
#   @image = image
#   @eports = e_ports
#   @volumes = vols
#   @environments = environs
#   @conf_self_start=false
#   @last_error=''
#   @last_result=''
#   @data_uid=data_uid
#   @data_gid=data_gid
#   @cont_userid=-1
#   @protocol=:http_and_https

class BuilderPublic
  def initialize(builder)
    @builder = builder
  end

  def engine_name
    @builder.container_name
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
    if @builder.http_protocol.nil? == true
      return ''
    end
    if @builder.http_protocol.include?('https')
      return 'https'
    end
    return 'http'
  end

  def repo_name
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
