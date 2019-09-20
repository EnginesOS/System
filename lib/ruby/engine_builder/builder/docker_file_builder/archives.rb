module Archives
  def write_app_archives
    unless @blueprint_reader.archives_details.nil?
      write_comment('#App Archives')
      log_build_output('Dockerfile:App Archives')
      @blueprint_reader.archives_details.each do |archive_details|
        next if archive_details[:download_type] == 'docker'

        check_args(archive_details)

        archive_details[:extraction_command] = 'false' if archive_details[:extraction_command].nil?

        pn = archive_details[:package_name].to_s
        extraction_command = archive_details[:extraction_command].to_s
        path_to_extracted = archive_details[:path_to_extracted].to_s
        path_to_extracted ='/' if path_to_extracted.nil? || path_to_extracted == ''
        args = ' \'' + archive_details[:download_type] + '\' '
        args += ' \'' + source_url(archive_details[:source_url], pn) + '\' '
        args += ' \'' + pn + '\' '
        args += ' \'' + extraction_command + '\' '
        args += ' \'' + archive_destination(archive_details[:destination]) + '\' '
        args += ' \'' + path_to_extracted + '\' '
        args += ' \'' + archive_details[:command_options].to_s + '\' '
        log_build_output('/build_scripts/package_installer.sh ' + args)
        write_run_line('/build_scripts/package_installer.sh ' + args)
      end
    end
  end

  private

  def archive_destination(dest)
    d =  dest.to_s
    if dest == './' || dest == '/'
      dest = ''
    elsif dest.end_with?('/')
      arc_loc = dest.chop # note not String#chop
    end

    # Destination can be /opt/ /home/app /home/fs/ /home/local/
    # If none of teh above then it is prefixed with /home/app
    dest = '/home/app/' + dest.to_s unless dest.start_with?('/opt') || dest.start_with?('/home/fs') || dest.start_with?('/home/app') || dest.start_with?('/home/local')
    dest = '/home/app' if dest.to_s == '/home/app/' || dest == '/'  || dest == './'  || dest == ''
    dest
  end

  def source_url(surl, pn)
    s = nil
    if @build_params.key?(:installed_packages)
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
    if pc[:type] == 'credentials'
      u = pc[:credentials][:username]
      p =  pc[:credentials][:password]
      url.sub!(/https:\/\//, 'https://' + u  + ':' + p + '@' )
    end
    url
  end

  def check_args(ad)
    ad[:download_type] = 'docker' if ad[:extraction_command] == 'docker'
    ad[:download_type] = 'git' if ad[:extraction_command] == 'git'
    ad[:download_type] = 'web' if ad[:download_type].nil?
  end
end
