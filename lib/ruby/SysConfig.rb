
class SysConfig

  @@addSiteCmd="ssh -i   /opt/engines/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.internal sudo sh /home/addsite.sh"
  @@rmSiteCmd="ssh -i  /opt/engines/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.internal sudo sh /home/rmsite.sh"
  @@addSiteMonitorCmd="ssh -i  /opt/engines/etc/keys/nagios  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.internal sudo sh /home/addsite.sh"
  @@rmSiteMonitorCmd="ssh -i  /opt/engines/etc/keys/nagios   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.internal sudo sh /home/rmsite.sh"               
  @@addDBServiceCmd="ssh  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"  -i /opt/engines/etc/keys/mysql rma@"  
  @@DBHost="mysql.engines.internal"
  @@CidDir="/opt/engines/run"
  @@ContainersDir="/opt/engines/run/containers/"
  @@DeploymentDir="/home/dockuser/deployment/deployed"
  @@DeploymentTemplates="/opt/engines/system/templates/deployment"
  @@CONTFSVolHome = "/home/app/fs"
  @@LocalFSVolHome = "/var/lib/engines/fs"
  @@galleriesDir = "/opt/engines/etc/galleries"
  @@ddnsKey = "/opt/engines/etc/keys/ddns.key"
  @@internalDomain = "engines.internal"
  @@defaultDNS ="172.17.42.1"
  @@timeZone_fileMapping=" -v /etc/localtime:/etc/localtime:ro "
  @@addBackupCmd = "ssh -i  /opt/engines/etc/keys/backup   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@backup.engines.internal sudo sh /home/add_backup.sh "
  @@rmBackupCmd = "ssh -i  /opt/engines/etc/keys/backup   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@backup.engines.internal sudo sh /home/rm_backup.sh "
  @@SystemLogRoot ="/var/log/engines/"
  @@HostedDomainsFile="/opt/engines/etc/hosted_domains"
  @@HttpNginxTemplate="/opt/engines/etc/nginx/tmpls/http_site.tmpl"
  @@HttpsNginxTemplate="/opt/engines/etc/nginx/tmpls/https_site.tmpl"
  @@HttpHttpsNginxTemplate="/opt/engines/etc/nginx/tmpls/http_to_https_site.tmpl"
  @@NginxSiteDir="/opt/engines/etc/nginx/sites-enabled/"
  @@NginxCertDir="/opt/engines/etc/nginx/ssl/certs"
  @@NginxDefaultCert="engines"
  @@SelfHostedDNStemplate="/opt/engines/etc/dns/tmpls/selfhosted.tmpl"
  @@DNSZoneDir="/opt/engines/etc/dns/config/zones/"
  @@DNSConfDir="/opt/engines/etc/dns/config/conf/"
  @@NamedPIDFile="/opt/engines/run/services/nginx/run/nginx/nginx.pid"
  @@DNSHostedList="/op/engines/etc/dns/config/conf/domains.hosted"
  
  def SysConfig.DNSHostedList
    return @@DNSHostedList
  end
  def SysConfig.NginxPIDFile
    return @@NamedPIDFile
  end
  def SysConfig.NamedPIDFile
     return @@NamedPIDFile
   end
     
  def SysConfig.DNSConfDir
    return @@DNSConfDir
  end
    
  def SysConfig.DNSZoneDir
    return @@DNSZoneDir
  end
  
  def SysConfig.SelfHostedDNStemplate
    return @@SelfHostedDNStemplate
  end
  
  def SysConfig.NginxDefaultCert
    return @@NginxDefaultCert
  end
  
  def SysConfig.NginxCertDir
    return @@NginxCertDir
  end
  def SysConfig.NginxSiteDir
    return @@NginxSiteDir
  end
  def SysConfig.HttpNginxTemplate
    return @@HttpNginxTemplate
  end
  def SysConfig.HttpsNginxTemplate
      return @@HttpsNginxTemplate
    end
  def SysConfig.HttpHttpsNginxTemplate
       return @@HttpHttpsNginxTemplate
     end
       
 def SysConfig.HostedDomainsFile
   return @@HostedDomainsFile
 end
 
  def SysConfig.SystemLogRoot
    return @@SystemLogRoot
  end
  def SysConfig.addBackupCmd
    return @@addBackupCmd
  end
  def SysConfig.rmBackupCmd
    return @@rmBackupCmd
  end
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