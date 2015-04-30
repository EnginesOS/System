class SystemAccess
  
  #This Class is the public face of the system
  #release etc
  
  def release
    return SystemUtils.system_release
   
  end
  
  def mysql_host
    return SysConfig.DBHost
  end
  
  def pqsql_host
    return "pgsql.engines.internal"
  end
  
  def smtp_host
    return SysConfig.SMTPHost
  end
  def timezone_city_country
    return "Australia/Sydney"
end
  def hrs_from_gmt
    return "+10"
  end
  def default_domain
    return SystemUtils.get_default_domain
  end
end