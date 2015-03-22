module BuildReport
  
  require_relative 'templating.rb'
  include Templating
  
  
  
  def get_build_report_template(blueprint)
    template = blueprint[:installation_report_template]
      if template == nil
        return get_default_build_report_template
      else
        return template
    end
  rescue
    return " Template load error "
  end
  
  def get_default_build_report_template
    return File.read(SysConfig.DefaultBuildReportTemplateFile)
    rescue
    return " No Default Template"
  end
  
  
  def generate_build_report(blueprint)
    report_template = get_build_report_template(blueprint)
    report = process_templated_string(report_template)
   return report
    
  end
  
end