class SysConfig

  #  @@addSiteCmd="ssh -i   /opt/engines/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.internal sudo sh /home/addsite.sh"
  #  @@rmSiteCmd="ssh -i  /opt/engines/etc/keys/nginx -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@nginx.engines.internal sudo sh /home/rmsite.sh"
  #  @@addSiteMonitorCmd="ssh -i  /opt/engines/etc/keys/nagios  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.internal sudo sh /home/addsite.sh"
  #  @@rmSiteMonitorCmd="ssh -i  /opt/engines/etc/keys/nagios   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@monit.engines.internal sudo sh /home/rmsite.sh"
  #  @@addDBServiceCmd="ssh  -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"  -i /opt/engines/etc/keys/mysql rma@"
  #
  @@api_version="0.0"
  @@engines_system_version="0.0"
  
  @@RegistryPort=21027
  
  @@default_webport=8000
  
  @@DBHost="mysql.engines.internal"
  @@RunDir="/opt/engines/run/"
  @@CidDir="/opt/engines/run/cid/"
  @@ContainersDir="/opt/engines/run/containers/"
  @@DeploymentDir="/home/engines/deployment/deployed"
  @@DeploymentTemplates="/opt/engines/system/templates/deployment"
  @@CONTFSVolHome = "/home/app/fs"
  @@LocalFSVolHome = "/var/lib/engines/fs"
  @@galleriesDir = "/opt/engines/etc/galleries"
  @@DefaultBuildReportTemplateFile="/opt/engines/system/templates/deployment/global/default_built_report_template"

  @@timeZone_fileMapping=" -v /etc/localtime:/etc/localtime:ro "

  @@addBackupCmd = "ssh -i  /opt/engines/etc/keys/backup   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@backup.engines.internal sudo sh /home/add_backup.sh "
  @@rmBackupCmd = "ssh -i  /opt/engines/etc/keys/backup   -o UserKnownHostsFile=/dev/null -o \"StrictHostKeyChecking no\"   rma@backup.engines.internal sudo sh /home/rm_backup.sh "

  @@SystemLogRoot ="/var/log/engines/"

  #System_public
  @@ReleaseFile="/opt/engines/release"
  #System_private
  @@DomainsFile="/opt/engines/etc/domains/domains"
  @@FirstRunRan="/opt/engines/run/system/flags/first_ran"
  @@SystemPreferencesFile="/opt/engines/etc/preferences/settings.yaml"

  #NGINX
#  @@HttpNginxTemplate="/opt/engines/etc/nginx/tmpls/http_site.tmpl"
#  @@HttpsNginxTemplate="/opt/engines/etc/nginx/tmpls/https_site.tmpl"
#  @@HttpHttpsNginxTemplate="/opt/engines/etc/nginx/tmpls/http_to_https_site.tmpl"
#  @@NginxSiteDir="/opt/engines/etc/nginx/sites-enabled/"
#  @@NginxCertDir="/opt/engines/etc/nginx/ssl/certs"
#  @@NginxDefaultCert="engines"
#  @@NginxPIDFile="/opt/engines/run/services/nginx/run/nginx/nginx.pid"
  #DNS
#  @@ddnsKey = "/opt/engines/etc/dns/keys/ddns.key"
#  @@internalDomain = "engines.internal"
#  @@defaultDNS ="172.17.42.1"

#  @@DefaultDomainnameFile="/opt/engines/etc/default_domain_name"
  
  #Named
#  @@NamedPIDFile="/opt/engines/run/services/dns/run/dns/named/named.pid"
#  @@SelfHostedDNStemplate="/opt/engines/etc/dns/tmpls/selfhosted.tmpl"
#  @@DNSZoneDir="/opt/engines/etc/dns/config/zones/"
#  @@DNSConfDir="/opt/engines/etc/dns/config/conf/"
 # @@HostedDomainsFile="/opt/engines/etc/hosted_domains"
  @@DNSHostedList="/opt/engines/etc/dns/config/conf/domains.hosted"

  #Cron
  @@CronDir = "/opt/engines/etc/cron/tabs"

  @@PreStartScript="/home/engines/scripts/pre-runnning.sh"
  @@InstallScript="/home/engines/scripts/custom_install.sh"
  @@StartScript="/home/engines/scripts/custom_start.sh"
  @@PostInstallScript="/home/engines/scripts/post_install.sh"
  @@ScriptsDir="/home/engines/scripts/"
  @@CustomPHPiniFile="/home/engines/configs/php/01-custom.ini"
  @@CustomApacheConfFile="/home/engines/configs/apache2/extra.conf"

  #service Manager
  @@ServiceTreeFile = "/opt/engines/run/service_manager/services.yaml"
  @@ServiceMapTemplateDir="/opt/engines/etc/services/mapping/"
  @@ServiceTemplateDir="/opt/engines/etc/services/providers/"
  @@SetupParamsScript="/bin/bash /home/setup_params.sh"
  
  ##SSH
  @@engines_ssh_private_keyfile="/home/engines/.ssh/sshaccess"
  @@generate_ssh_private_keyfile="/opt/engines/bin/new_engines_user_key.sh"
  @@SMTPHost="smtp.engines.internal"
  
  def SysConfig.RegistryPort
    return @@RegistryPort
  end
  def SysConfig.api_version
    return @@api_version
  end
  @@api_version="0.0"
  @@engines_system_version="0.0"
  def SysConfig.engines_system_version
    return @@engines_system_version
  end
  
  @@EnginesInternalCA="/opt/engines/etc/ssl/ca/certs/system_CA.pem"
  #/opt/engines/etc/ca/engines_internal_ca.crt"
  
  def SysConfig.default_webport
    return @@default_webport
  end
  
  def SysConfig.RunDir
    return @@RunDir
  end
  def SysConfig.EnginesInternalCA
    return @@EnginesInternalCA
  end
  
  def SysConfig.SystemPreferencesFile
    return @@SystemPreferencesFile
  end
  def SysConfig.engines_ssh_private_keyfile
    return @@engines_ssh_private_keyfile
  end
  
  def SysConfig.DefaultBuildReportTemplateFile
    return @@DefaultBuildReportTemplateFile
  end

  def SysConfig.DefaultDomainnameFile
    return @@DefaultDomainnameFile
  end

  def SysConfig.SMTPHost
    return @@SMTPHost
  end

  def SysConfig.CustomApacheConfFile
    return @@CustomApacheConfFile
  end

  def SysConfig.CustomPHPiniFile
    return @@CustomPHPiniFile
  end

  def SysConfig.ScriptsDir
    return @@ScriptsDir
  end

  def SysConfig.PreStartScript
    return @@PreStartScript
  end

  def SysConfig.StartScript
    return @@StartScript
  end

  def SysConfig.InstallScript
    return @@InstallScript
  end

  def SysConfig.PostInstallScript
    return @@PostInstallScript
  end

  def SysConfig.SetupParamsScript
    return @@SetupParamsScript
  end

  def  SysConfig.ReleaseFile
    return @@ReleaseFile
  end

  def SysConfig.ServiceMapTemplateDir
    return @@ServiceMapTemplateDir
  end

  def SysConfig.ServiceTreeFile
    return @@ServiceTreeFile
  end

  def SysConfig.ServiceTemplateDir
    return @@ServiceTemplateDir
  end

  def SysConfig.CronDir
    return @@CronDir
  end

  def SysConfig.DomainsFile
    return @@DomainsFile
  end

  def SysConfig.FirstRunRan
    return @@FirstRunRan
  end

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

#  def SysConfig.HostedDomainsFile
#    return @@HostedDomainsFile
#  end

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