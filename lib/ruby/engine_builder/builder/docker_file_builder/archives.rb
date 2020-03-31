module Archives
  def write_app_archives
    unless @blueprint_reader.archives_details.nil?
      write_comment('#App Archives')
      log_build_output('Dockerfile:App Archives')
      @blueprint_reader.archives_details.each do |archive_details|
        next if archive_details[:download_type] == 'docker'
        check_args(archive_details)
        args = extract_args(archive_details)
        log_build_output("/build_scripts/package_installer.sh #{args}")
        write_run_line("/build_scripts/package_installer.sh #{args}")
      end
    end
  end

  protected

  def extract_args(ad)
    ad[:extraction_command] = 'false' if ad[:extraction_command].nil?
    args = " '#{ad[:download_type]}' "
    pn = "#{ad[:package_name]}"
    args += " ' #{source_url(ad[:source_url], pn)}' "
    args += " '#{pn}'"
    args += " '#{ad[:extraction_command]}' "
    args += " '#{archive_destination(ad[:destination])}' "
    args += " '#{path_to_extraced(ad)}' "
    args += " '#{ad[:command_options]}' "
  end

  def path_to_extraced(ad)
    if ad[:path_to_extracted].nil? || ad[:path_to_extracted] == ''
      '/'
    else
      ad[:path_to_extracted]
    end
  end

  def archive_destination(dest)
    d = dest.to_s
    if dest == './' || dest == '/'
      dest = ''
    elsif dest.end_with?('/')
      arc_loc = dest.chop # note not String#chop
    end
    # Destination can be /opt/ /home/app /home/fs/ /home/local/
    # If none of teh above then it is prefixed with /home/app
    dest = "/home/app/#{dest}" unless dest.start_with?('/opt') || dest.start_with?('/home/fs') || dest.start_with?('/home/app') || dest.start_with?('/home/local')
    dest = '/home/app' if dest.to_s == '/home/app/' || dest == '/'  || dest == './'  || dest == ''
    dest
  end

  def source_url(surl, pn)
    s = nil
    unless @build_params[:installed_packages].nil?
      if @build_params[:installed_packages].key?(pn.to_sym)
        s = authenticated_source(
        surl,
        @build_params[:installed_packages][pn.to_sym])
      end
    end
    s = surl.to_s if s.nil?
    s
  end

  def
  authenticated_source(url, pc)
    unless pc[:type].nil?
      if pc[:type] == 'credentials'
        u = pc[:credentials][:username]
        p =  pc[:credentials][:password]
        url.sub!(/https:\/\//, 'https://' + u  + ':' + p + '@' )
      end
    end
    url
  end

  def check_args(ad)
    ad[:download_type] = 'docker' if ad[:extraction_command] == 'docker'
    ad[:download_type] = 'git' if ad[:extraction_command] == 'git'
    ad[:download_type] = 'web' if ad[:download_type].nil?
  end
end
