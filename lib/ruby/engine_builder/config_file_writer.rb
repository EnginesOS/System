class ConfigFileWriter    
  
  def self.compile_base_docker_files(templater, basedir)
    file_list = Dir.glob(basedir + '/Dockerfile*.tmpl')
    file_list.each do |file|
      return false unless process_dockerfile_tmpl(templater, file)             
    end
    return true
  end
  
  def self.write_software_file(templater, container_filename_path, content)
      content.gsub!(/\r/, '')
      dir = File.dirname(get_basedir + container_filename_path)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      out_file  = File.open(get_basedir + container_filename_path, 'wb', :crlf_newline => false)
      content = templater.process_templated_string(content)
      out_file.puts(content)
      out_file.close
      return true
    rescue StandardError => e
      SystemUtils.log_exception(e)
    end
  
    def self.process_dockerfile_tmpl(templater,filename)
      template = File.read(filename)
      template = templater.process_templated_string(template)
      output_filename = filename.sub(/.tmpl/, '')
      out_file = File.new(output_filename, 'wb')
      out_file.write(template)
      out_file.close
      return true
      rescue StandardError => e
      SystemUtils.log_exception(e)
    end  
end
