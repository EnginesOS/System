
class SysConfig

  @@addSiteCmd="ssh -i   /opt/engos/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.local sudo sh /home/addsite.sh"
  @@rmSiteCmd="ssh -i  /opt/engos/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.local sudo sh /home/rmsite.sh"
  @@addSiteMonitorCmd="ssh -i  /opt/engos/etc/keys/nagios  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.local sudo sh /home/addsite.sh"
  @@rmSiteMonitorCmd="ssh -i  /opt/engos/etc/keys/nagios   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.local sudo sh /home/rmsite.sh"               
  @@addDBServiceCmd="ssh  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"  -i /opt/engos/etc/keys/mysql rma@mysql.engines.local  /home/createdb.sh "
  @@DBHost="mysql.engines.local"
  @@CidDir="/opt/engos/run"
  @@ContainersDir="/opt/engos/run/containers/"
  @@DeploymentDir="/home/dockuser/droplets/deployment/deployed"
  @@DeploymentTemplates="/opt/engos/system/templates/deployment"
  @@CONTFSVolHome = "/home/app/fs"
  @@LocalFSVolHome = "/var/engos/fs"
  @@galleriesDir = "/opt/engos/etc/galleries"
  @@ddnsKey = "/opt/engos/etc/keys/ddns.key"
  @@internalDomain = "engines.local"
  @@defaultDNS ="172.17.42.1"
  @@timeZone_fileMapping=" -v /etc/localtime:/etc/localtime "

  def SysConfig.timeZone_fileMapping
    return @@timeZone_fileMapping
  end
  def SysConfig.defaultDNS
    return @@defaultDNS
  end
  def SysConfig.internalDomain 
    return @@internalDomain
  end
  
  def SysConfig.ddnsKey
    return @@ddnsKey
  end
  
  def SysConfig.galleriesDir
      return @@galleriesDir
  end
  
  def SysConfig.ContainersDir
    return @@ContainersDir
  end
  
  def SysConfig.LocalFSVolHome
    return @@LocalFSVolHome
  end
  
  def SysConfig.CONTFSVolHome 
    return @@CONTFSVolHome 
  end
  
  def SysConfig.DBHost
    return @@DBHost
  end
  
  def SysConfig.addDBServiceCmd
    return@@addDBServiceCmd
  end
  
  def SysConfig.DeploymentTemplates
    return @@DeploymentTemplates
  end
  
  def SysConfig.addSiteCmd
    return @@addSiteCmd
  end
  
 def SysConfig.rmSiteCmd
   return @@rmSiteCmd
 end
 
 def SysConfig.addSiteMonitorCmd
   return @@addSiteMonitorCmd
 end
 
 def SysConfig.rmSiteMonitorCmd
   return @@rmSiteMonitorCmd
 end
  
  def SysConfig.CidDir
    return @@CidDir
  end
  
  def SysConfig.DeploymentDir
    return @@DeploymentDir
  end
end