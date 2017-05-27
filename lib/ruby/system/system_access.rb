class SystemAccess
  def initialize(system)
    @engines_api = system
  end

  #This Class is the public face of the system
  #release etc
  def release
    SystemUtils.system_release
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
    @engines_api.get_timezone
    #  olsontz = File.read('/etc/timezone')
    #    olsontz = `if [ -f /etc/timezone ]; then
    #      cat /etc/timezone
    #    elif [ -h /etc/localtime ]; then
    #      readlink /etc/localtime | sed "s/\\/usr\\/share\\/zoneinfo\\///"
    #    else
    #      checksum=\`md5sum /etc/localtime | cut -d' ' -f1\`
    #      find /usr/share/zoneinfo/ -type f -exec md5sum {} \\; | grep "^$checksum" | sed "s/.*\\/usr\\/share\\/zoneinfo\\///" | head -n 1
    #    fi`.chomp
    #    return "  " if olsontz.nil?
    #     olsontz
  end

  def  timezone
    Time.now.getlocal.zone
  end

  def hrs_from_gmt
    m = Time.now.getlocal.gmt_offset
    return m.to_s if m == 0
    (m / 3600).to_s
  end

  def default_domain
    prefs = SystemPreferences.new()
    prefs.get_default_domain
  end

  def internal_domain
    'engines.internal'
  end

  def publickey
    @engines_api.get_public_key()
  end

  def pubkey(type)
    return '' if @engines_api.nil?
    args = type.split('_')
    engine = args[0]
    cmd = args[1]
    cmd.gsub!(/\)/, '')

    @engines_api.get_service_pubkey(engine, cmd)
  end

  def random cnt
    len = cnt.to_i
    rnd = SecureRandom.hex(len)
    rnd.byteslice(0,len)
  end

  def service_resource(service_name, what)
    @engines_api.service_resource(service_name, what)
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
    #    require 'socket'
    #
    #    addr_infos = Socket.ip_address_list
  end

  def system_hostname
    @engines_api.system_hostname
  end

end