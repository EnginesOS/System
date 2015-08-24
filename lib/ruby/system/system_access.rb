class SystemAccess
  
  #This Class is the public face of the system
  #release etc
  
  def release
    return SystemUtils.system_release   
  end
  
  def pgsql_host
    return 'pgsql.engines.internal'
  end 
  
  def mysql_host
    return SystemConfig.DBHost
  end 
  
  def smtp_host
    return SystemConfig.SMTPHost
  end
  
  def timezone_country_city
    # FIXME: Needs to be real
    return 'Australia/Sydney'
end

  def hrs_from_gmt
    # FIXME: Needs to be real
    return '+10'
  end
  
  def default_domain
    prefs = SystemPreferences.new()
    return  prefs.get_default_domain   
  end
    
  def pubkey type
    args = type.split('_')
      engine = args[0]
      cmd = args[1]
      cmd.gsub!(/\)/,'')
    return  SystemUtils.get_service_pubkey(engine,cmd)      
  end
  
  def random cnt
    len = cnt.to_i
    rnd = SecureRandom.hex(len)
 #       p :RANDOM__________
 #       p rnd.byteslice(0,len) 
    return rnd.byteslice(0,len) 
  end
  
end