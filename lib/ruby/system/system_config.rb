class SystemConfig


  @@api_version='0.0'
  @@engines_system_version='0.0'
  
  @@RegistryPort=21027
  
  @@default_webport=8000
  
  @@DBHost='mysql.engines.internal'
  @@RunDir='/opt/engines/run/'
  @@CidDir='/opt/engines/run/cid/'
  @@ContainersDir='/opt/engines/run/containers/'
  @@DeploymentDir='/home/engines/deployment/deployed'
  @@DeploymentTemplates='/opt/engines/system/templates/deployment'
  @@CONTFSVolHome = '/home/app/fs'
  @@LocalFSVolHome = '/var/lib/engines/fs'
  @@galleriesDir = '/opt/engines/etc/galleries'
  @@DefaultBuildReportTemplateFile='/opt/engines/system/templates/deployment/global/default_built_report_template'

  @@timeZone_fileMapping=' -v /etc/localtime:/etc/localtime:ro '

  @@internal_domain='engines.internal'
  @@SystemLogRoot ='/var/log/engines/'

  #System_public
  @@ReleaseFile='/opt/engines/release'
  #System_private
  @@DomainsFile='/opt/engines/etc/domains/domains'
  @@FirstRunRan='/opt/engines/run/system/flags/first_ran'
  @@SystemPreferencesFile='/opt/engines/etc/preferences/settings.yaml'



  @@PreStartScript='/home/engines/scripts/pre-runnning.sh'
  @@InstallScript='/home/engines/scripts/custom_install.sh'
  @@StartScript='/home/engines/scripts/custom_start.sh'
  @@PostInstallScript='/home/engines/scripts/post_install.sh'
  @@ScriptsDir='/home/engines/scripts/'
  @@CustomPHPiniFile='/home/engines/configs/php/01-custom.ini'
  @@CustomApacheConfFile='/home/engines/configs/apache2/extra.conf'

  #service Manager
  
  #@@ServiceTreeFile = '/opt/engines/run/service_manager/services.yaml'
  @@ServiceMapTemplateDir='/opt/engines/etc/services/mapping/'
  @@ServiceTemplateDir='/opt/engines/etc/services/providers/'
  @@SetupParamsScript='/bin/bash /home/setup_params.sh'
  
  ##SSH
  @@engines_ssh_private_keyfile='/home/engines/.ssh/sshaccess'
  @@generate_ssh_private_keyfile='/opt/engines/bin/new_engines_user_key.sh'
  @@SMTPHost='smtp.engines.internal'
  @@EnginesSystemUpdatedFlag='/opt/engines/run/system/flags/update_engines_run'
  @@EnginesSystemUpdatingFlag='/opt/engines/run/system/flags/update_engines_running'
  @@SystemUpdatedFlag='/opt/engines/run/system/flags/update_run'
  @@SystemUpdatingFlag='/opt/engines/run/system/flags/update_running'
  @@EnginesSystemRebootNeededFlag='/opt/engines/run/system/flags/reboot_required'
  @@SystemRebootingFlag='/opt/engines/run/system/flags/engines_rebooting'
  
  @@BuildBuiltFile='/opt/engines/run/system/flags/last_build_params'
  @@BuildRunningParamsFile='/opt/engines/run/system/flags/building_params'
  @@BuildFailedFile='/opt/engines/run/system/flags/last_build_fail'
  
  def SystemConfig.generate_ssh_private_keyfile
    return  @@generate_ssh_private_keyfile
  end
  def SystemConfig.BuildBuiltFile
    return  @@BuildBuiltFile
  end
  
  def SystemConfig.BuildRunningParamsFile
    return @@BuildRunningParamsFile
  end
  
  def SystemConfig.BuildFailedFile
    return @@BuildFailedFile
  end
  def SystemConfig.SystemRebootingFlag
    return @@SystemRebootingFlag
  end 
  def SystemConfig.EnginesSystemRebootNeededFlag
    return @@EnginesSystemRebootNeededFlag
  end
  
  def SystemConfig.EnginesSystemUpdatedFlag
    return   @@EnginesSystemUpdatedFlag
  end
  def SystemConfig.EnginesSystemUpdatingFlag
    return   @@EnginesSystemUpdatingFlag
  end  
  def SystemConfig.SystemUpdatingFlag
    return   @@SystemUpdatingFlag
  end
  def SystemConfig.SystemUpdatedFlag
     return   @@SystemUpdatedFlag
  end
   
  
  def SystemConfig.RegistryPort
    return @@RegistryPort
  end
  def SystemConfig.api_version
    return @@api_version
  end
  @@api_version='0.0'
  @@engines_system_version='0.0'
  def SystemConfig.engines_system_version
    return @@engines_system_version
  end
  
  @@EnginesInternalCA='/opt/engines/etc/ssl/ca/certs/system_CA.pem'
  #/opt/engines/etc/ca/engines_internal_ca.crt'
  
  def SystemConfig.default_webport
    return @@default_webport
  end
  
  def SystemConfig.RunDir
    return @@RunDir
  end
  def SystemConfig.EnginesInternalCA
    return @@EnginesInternalCA
  end
  
  def SystemConfig.SystemPreferencesFile
    return @@SystemPreferencesFile
  end
  def SystemConfig.engines_ssh_private_keyfile
    return @@engines_ssh_private_keyfile
  end
  
  def SystemConfig.DefaultBuildReportTemplateFile
    return @@DefaultBuildReportTemplateFile
  end
#
#  def SystemConfig.DefaultDomainnameFile
#    return @@DefaultDomainnameFile
#  end

  def SystemConfig.SMTPHost
    return @@SMTPHost
  end

  def SystemConfig.CustomApacheConfFile
    return @@CustomApacheConfFile
  end

  def SystemConfig.CustomPHPiniFile
    return @@CustomPHPiniFile
  end

  def SystemConfig.ScriptsDir
    return @@ScriptsDir
  end

  def SystemConfig.PreStartScript
    return @@PreStartScript
  end

  def SystemConfig.StartScript
    return @@StartScript
  end

  def SystemConfig.InstallScript
    return @@InstallScript
  end

  def SystemConfig.PostInstallScript
    return @@PostInstallScript
  end

  def SystemConfig.SetupParamsScript
    return @@SetupParamsScript
  end

  def  SystemConfig.ReleaseFile
    return @@ReleaseFile
  end

  def SystemConfig.ServiceMapTemplateDir
    return @@ServiceMapTemplateDir
  end



  def SystemConfig.ServiceTemplateDir
    return @@ServiceTemplateDir
  end


  def SystemConfig.DomainsFile
    return @@DomainsFile
  end

  def SystemConfig.FirstRunRan
    return @@FirstRunRan
  end

#

  def SystemConfig.SystemLogRoot
    return @@SystemLogRoot
  end

  def SystemConfig.timeZone_fileMapping
    return @@timeZone_fileMapping
  end

#  def SystemConfig.defaultDNS
#    return @@defaultDNS
#  end

  def SystemConfig.internal_domain
    return @@internal_domain
  end


  def SystemConfig.galleriesDir
    return @@galleriesDir
  end

  def SystemConfig.ContainersDir
    return @@ContainersDir
  end

  def SystemConfig.LocalFSVolHome
    return @@LocalFSVolHome
  end

  def SystemConfig.CONTFSVolHome
    return @@CONTFSVolHome
  end

  def SystemConfig.DBHost
    return @@DBHost
  end
#
#  def SystemConfig.addDBServiceCmd
#    return@@addDBServiceCmd
#  end

  def SystemConfig.DeploymentTemplates
    return @@DeploymentTemplates
  end

#

  def SystemConfig.CidDir
    return @@CidDir
  end

  def SystemConfig.DeploymentDir
    return @@DeploymentDir
  end
end