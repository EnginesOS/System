class ConfigFileWriter
  def self.compile_base_docker_files(templater, basedir)
    file_list = Dir.glob(basedir + '/Dockerfile*.tmpl')
    file_list.each do |file|
      return false unless process_dockerfile_tmpl(templater, file)
    end
    return true
  end

  def self.write_templated_file(templater, filename, content)
    content.gsub!(/\r/, '')
    dir = File.dirname(filename)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    out_file  = File.open(filename, 'wb', :crlf_newline => false)
    content = templater.process_templated_string(content)
    out_file.write(content)
    out_file.close
    return true
  rescue StandardError => e
    SystemUtils.log_error("Exception with " + filename.to_s )
    SystemUtils.log_exception(e)
  end

  def self.process_dockerfile_tmpl(templater,filename)
    template = File.read(filename)
    template = templater.process_templated_string(template)
    output_filename = filename.sub(/.tmpl/, '')
    out_file = File.new(output_filename, 'wb', :crlf_newline => false)
    out_file.write(template)
    out_file.close
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
end
