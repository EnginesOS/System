class ConfigFileWriter < ErrorsApi
  def self.compile_base_docker_files(templater, basedir)
    file_list = Dir.glob("#{basedir}/Dockerfile*.tmpl")
    file_list.each do |file|
      process_dockerfile_tmpl(templater, file)
    end
  end

  def self.create_sudoers_file(sudo_list, user, basedir)
    if sudo_list.is_a?(Array) && sudo_list.count > 0
      out_file = File.new("#{basedir}/sudo_list", 'w+', :crlf_newline => false)
      begin
        sudo_list.each do |entry|
          out_file.puts("#{user} ALL=(ALL) NOPASSWD: #{entry}")
        end
        out_file.puts("\n")
      ensure
        out_file.puts("\n")
        out_file.close
      end
    end
  end

  def self.write_templated_file(templater, filename, content)
    if content.nil?
    SystemUtils.log_error("NO Content for #{filename}")
    else
      content.gsub!(/\r/, '')
      dir = File.dirname(filename)
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      out_file  = File.open(filename, 'wb', :crlf_newline => false)
      begin
        content = templater.process_templated_string(content)
        out_file.write(content)
      ensure
        out_file.close
      end
    end
  end

  def self.process_dockerfile_tmpl(templater, filename)
    template = File.read(filename)
    template = templater.process_templated_string(template)
    output_filename = filename.sub(/.tmpl/, '')
    out_file = File.new(output_filename, 'wb', :crlf_newline => false)
    begin
      out_file.write(template)
    ensure
      out_file.close
    end
  end
end
