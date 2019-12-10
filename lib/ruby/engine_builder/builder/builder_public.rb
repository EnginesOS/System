require 'securerandom'

class BuilderPublic
  class << self
    def instance
      @@instance ||= self.new
    end
  end

  def ctype
    'app'
  end

  def cont_user_id
    builder.cont_user_id
  end

  def engine_name
    builder.memento.container_name
  end

  def environments
    builder.environments
  end

  def memory
    builder.memento.memory
  end

  def hostname
    builder.memento.hostname
  end

  def domain_name
    builder.memento.domain_name
  end

  def repository
    builder.memento.repository
  end

  def http_protocol
    unless builder.memento.http_protocol.nil?
      if builder.memento.http_protocol.include?('_')
        builder.memento.http_protocol.gsub!(/_.*/, '')
      else
        builder.memento.http_protocol
      end
    else
      nil
    end
  end

  def fqdn
    "#{hostname}.#{domain_name}"
  end

  def domain
    domain_name
  end

  def web_port
    builder.web_port
  end

  def build_name
    builder.build_name
  end

  def runtime
    builder.runtime
  end

  def set_environments
    builder.set_environments
  end

  def engine_environment
    builder.engine_environment
  end

  def blueprint
    builder.blueprint
  end

  def logs_container
    builder.running_logs
  end

  def data_gid
    builder.data_gid
  end

  def group_uid
    builder.data_gid
  end

  def data_uid
    builder.data_uid
  end

  def memory
    builder.memento.memory
  end

  def service_account(suffix=nil)

  end

  def service_password(cnt=8)

  end

  def fw_user
    builder.cont_user_id
  end

  def builder
     @builder ||= EngineBuilder.instance
   end
end
