class SystemAccess
  class << self
    def instance
      @@instance ||= self.new
    end
  end

  def release
    SystemUtils.system_release
  end

  def flavor
    SystemUtils.system_flavor
  end

  def pgsql_host
    'pgsql.engines.internal'
  end

  def mysql_host
    SystemConfig.DBHost
  end

  def mongo_host
    'mongo.engines.internal'
  end

  def internal_domain
    'engines.internal'
  end

  def smtp_host
    SystemConfig.SMTPHost
  end

  def timezone_country_city
    core.get_timezone
  end

  def timezone
    Time.now.getlocal.zone
  end

  def hrs_from_gmt
    m = Time.now.getlocal.gmt_offset
    if m == 0
      m.to_s
    else
      (m / 3600).to_s
    end
  end

  def default_domain
    prefs = SystemPreferences.new()
    prefs.default_domain
  end

  def internal_domain
    'engines.internal'
  end

  def publickey
    core.get_public_key()
  end

  def pubkey(type)
    args = type.split('_')
    engine = args[0]
    cmd = args[1]
    cmd.gsub!(/\)/, '')
    core.get_service_pubkey(engine, cmd)
  end

  def random(cnt)
    len = cnt.to_i
    rnd = SecureRandom.hex(len)
    rnd.byteslice(0, len)
  end

  def service_resource(service_name, what)
    #  STDERR.puts('SERVICE RESOURCE ')
    core.service_resource(service_name, what)
  end

  # where ssh goes
  def mgmt_host
    # FixME read docker0 ip or cmd line option
    '172.17.0.1'
  end

  # where ssh goes
  def system_ip
    # FixME read docker0 ip or cmd line option
    ENV['SYSTEM_IP']
  end

  # docker interface addres
  def docker_ip
    # FixME read docker0 ip or cmd line option
    '172.17.0.1'
  end

  def system_hostname
    core.system_hostname
  end

  protected

  def core
    @core ||= EnginesCore.instance
  end
end
