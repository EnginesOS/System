require 'securerandom'

class BuilderPublic
  def initialize(builder)
    @builder = builder
  end

  def ctype
    'app'
  end

  def cont_user_id
    @builder.cont_user_id
  end

  def engine_name
    @builder.build_params[:engine_name]
  end

  def environments
    @builder.environments
  end

  def memory
    @builder.build_params[:memory]
  end

  def hostname
    @builder.build_params[:host_name]
  end

  def domain_name
    @builder.build_params[:domain_name]
  end

  def repository
    @builder.build_params[:repository_url]
  end

  def http_protocol
    if @builder.build_params.key?(:http_protocol)
      if @builder.build_params[:http_protocol].include?('_')
        @builder.build_params[:http_protocol].gsub!(/_.*/, '')
      else
        @builder.build_params[:http_protocol]
      end
    else
      nil
    end
  end

  def fqdn
    hostname + '.' + domain_name
  end

  def domain
    domain_name
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

  def logs_container
    @builder.running_logs
  end

  def data_gid
    @builder.data_gid
  end

  def group_uid
    @builder.data_gid
  end

  def data_uid
    @builder.data_uid
  end

  def memory
    @builder.build_params[:memory]
  end
  #  require 'hmac-md5'
  #  def md5_sum(password)
  #    HMAC::MD5.new(password).digest
  #  end

  def service_account(suffix=nil)

  end

  def service_password(cnt=8)

  end
  
  def fw_user
    @builder.cont_user_id
  end


end
