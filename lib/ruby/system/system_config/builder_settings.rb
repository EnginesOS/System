module BuilderSettings

  @@BuildBuiltFile = '/opt/engines/run/system/flags/last_build_params'
  @@BuildRunningParamsFile = '/opt/engines/run/system/flags/building_params'
  @@BuildFailedFile = '/opt/engines/run/system/flags/last_build_fail'
  @@DefaultBuildReportTemplateFile = '/opt/engines/system/templates/deployment/global/default_built_report_template'

  @@PreStartScript = '/home/engines/scripts/pre-runnning.sh'
  @@InstallScript = '/home/engines/scripts/custom_install.sh'
  @@StartScript = '/home/engines/scripts/custom_start.sh'
  @@PostInstallScript= '/home/engines/scripts/post_install.sh'
  @@ScriptsDir = '/home/engines/scripts/'
  @@CustomPHPiniFile = '/home/engines/configs/php/01-custom.ini'
  @@CustomApacheConfFile = '/home/engines/configs/apache2/extra.conf'
  @@SetupParamsScript = '/bin/bash /home/setup_params.sh'
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