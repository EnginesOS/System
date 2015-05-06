class SystemAccess
  
  #This Class is the public face of the system
  #release etc
  
  def release
    return SystemUtils.system_release   
  end

  
  def mysql_host
    return SysConfig.DBHost
  end 
  
  def smtp_host
    return SysConfig.SMTPHost
  end
  def timezone_country_city
    return "Australia/Sydney"
end
  def hrs_from_gmt
    return "+10"
  end
  def default_domain
    return SystemUtils.get_default_domain
  end
    
  def random cnt
    len = cnt.to_i
    rnd = SecureRandom.hex(len)
 #       p :RANDOM__________
 #       p rnd.byteslice(0,len) 
    return rnd.byteslice(0,len) 
  end
  
end