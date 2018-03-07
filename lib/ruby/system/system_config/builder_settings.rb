module BuilderSettings

  @@BuildBuiltFile = '/opt/engines/run/system/flags/last_build_params'
  @@BuildRunningParamsFile = '/opt/engines/run/system/flags/building_params'
  @@BuildFailedFile = '/opt/engines/run/system/flags/last_build_fail'
  @@DefaultBuildReportTemplateFile = '/opt/engines/system/templates/deployment/global/default_built_report_template'
  @@BuildOutputFile = '/home/engines/deployment/deployed/build.out'
  @@PreStartScript = '/home/engines/scripts/engine/pre-runnning.sh'
  @@InstallScript = '/home/engines/scripts/engine/custom_install.sh'
  @@StartScript = '/home/engines/scripts/engine/custom_start.sh'
  @@PostInstallScript = '/home/engines/scripts/engine/post_install.sh'
  @@ScriptsDir = '/home/engines/scripts/engine/'
  @@CustomPHPiniFile = '/home/engines/configs/php/01-custom.ini'
  @@CustomApacheConfFile = '/home/engines/configs/apache2/extra.conf'
#  @@SetupParamsScript = '/bin/bash /home/setup_params.sh'
  @@ActionatorDir = '/home/engines/scripts/actionators/'
  @@BackupScriptsRoot = '/home/engines/services/'
  @@BackupScriptsSrcRoot = '/opt/engines/system/templates/services/backup/'
  @@LanguageFile = '/opt/engines/etc/locale'
  @@DefaultLanguage = 'en'
  @@DefaultCountry = 'US'
  @@StopScript = '/home/engines/scripts/engine/custom_stop.sh'
  @@htaccessSourceDir = '/home/engines/htaccess_files/'


  def SystemConfig.htaccessSourceDir
    @@htaccessSourceDir
  end

  def SystemConfig.LanguageFile
    @@LanguageFile
  end

  def SystemConfig.DefaultLanguage
    @@DefaultLanguage
  end

  def SystemConfig.DefaultCountry
    @@DefaultCountry
  end

  def SystemConfig.Language
    if File.exist?(SystemConfig.LanguageFile)
      File.read(SystemConfig.LanguageFile).strip
    else
      SystemConfig.DefaultLanguage
    end
  rescue
    SystemConfig.DefaultLanguage
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
    @@SetupParamsScript
  end

  def SystemConfig.CustomApacheConfFile
    @@CustomApacheConfFile
  end

  def SystemConfig.CustomPHPiniFile
    @@CustomPHPiniFile
  end

  def SystemConfig.ScriptsDir
    @@ScriptsDir
  end

  def SystemConfig.PreStartScript
    @@PreStartScript
  end

  def SystemConfig.StartScript
    @@StartScript
  end

  def SystemConfig.StopScript
    @@StopScript
  end

  def SystemConfig.InstallScript
    @@InstallScript
  end

  def SystemConfig.PostInstallScript
    @@PostInstallScript
  end

  def SystemConfig.BuildFailedFile
    @@BuildFailedFile
  end

  def SystemConfig.BuildBuiltFile
    @@BuildBuiltFile
  end

  def SystemConfig.BuildRunningParamsFile
    @@BuildRunningParamsFile
  end

  def SystemConfig.DefaultBuildReportTemplateFile
    @@DefaultBuildReportTemplateFile
  end
end