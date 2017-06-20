module BuildReport
  def get_build_report_template(blueprint)
    if @blueprint_reader.install_report_template.nil?
      get_default_build_report_template
    else    
    @blueprint_reader.install_report_template
    end
  end

  def get_default_build_report_template
    File.read(SystemConfig.DefaultBuildReportTemplateFile)
  rescue Exception => e
    p e
    ' No Default Template'
  end

  def generate_build_report(templater, blueprint)
    report_template = get_build_report_template(blueprint)
    templater.process_templated_string(report_template)
  end
end
