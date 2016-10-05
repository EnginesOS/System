module BuilderSettings

  @@BuildBuiltFile = '/opt/engines/run/system/flags/last_build_params'
  @@BuildRunningParamsFile = '/opt/engines/run/system/flags/building_params'
  @@BuildFailedFile = '/opt/engines/run/system/flags/last_build_fail'
  @@DefaultBuildReportTemplateFile = '/opt/engines/system/templates/deployment/global/default_built_report_template'
  @@BuildOutputFile = '/home/engines/deployment/deployed/build.out'
  @@PreStartScript = '/home/engines/scripts/pre-runnning.sh'
  @@InstallScript = '/home/engines/scripts/custom_install.sh'
  @@StartScript = '/home/engines/scripts/custom_start.sh'
  @@PostInstallScript= '/home/engines/scripts/post_install.sh'
  @@ScriptsDir = '/home/engines/scripts/'
  @@CustomPHPiniFile = '/home/engines/configs/php/01-custom.ini'
  @@CustomApacheConfFile = '/home/engines/configs/apache2/extra.conf'
  @@SetupParamsScript = '/bin/bash /home/setup_params.sh'
  @@ActionatorDir = '/home/actionators/'
  @@BackupScriptsRoot = '/home/services/'
  @@BackupScriptsSrcRoot = '/opt/engines/system/templates/services/backup/'
  @@LanguageFile = '/opt/engines/etc/locale'
  @@DefaultLanguage = 'en_US'
  
  def SystemConfig.LanguageFile
    @@LanguageFile
  end
  
  def SystemConfig.DefaultLanguage
      @@DefaultLanguage
    end
    
  def SystemConfig.Language
    return File.read(SystemConfig.LanguageFile).strip if File.exist?(SystemConfig.LanguageFile) 
    return SystemConfig.DefaultLanguage
  rescue
    return SystemConfig.DefaultLanguage
   end
   
  def SystemConfig.BuildOutputFile
    @@BuildOutputFile
  end
   def SystemConfig.BackupScriptsSrcRoot
     @@BackupScriptsSrcRoot
   end
  def SystemConfig.BackupScriptsRoot
    @@BackupScriptsRoot
  end
  
  def SystemConfig.ActionatorDir
    @@ActionatorDir
  end

  def SystemConfig.SetupParamsScript
    return @@SetupParamsScript
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

  def SystemConfig.BuildFailedFile
    return @@BuildFailedFile
  end

  def SystemConfig.BuildBuiltFile
    return  @@BuildBuiltFile
  end

  def SystemConfig.BuildRunningParamsFile
    return @@BuildRunningParamsFile
  end
  def SystemConfig.DefaultBuildReportTemplateFile
     return @@DefaultBuildReportTemplateFile
   end
end