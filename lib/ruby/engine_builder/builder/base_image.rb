def read_base_image_from_dockerfile
  
    dockerfile = File.open(basedir + '/Dockerfile', 'r')
    from_line = dockerfile.gets("\n", 100)
    from_line.gsub!(/^FROM[ ]./, '')
  dockerfile.close
  from_line
  rescue StandardError => e
    log_build_errors(e)
    return post_failed_build_clean_up
  end
  
  def get_base_image
    base_image_name = read_base_image_from_dockerfile

    if base_image_name.nil?
      log_build_errors('Failed to Read Image from Dockerfile')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    end
    log_build_output('Pull base Image')
#    if
      @core_api.pull_image(base_image_name) #== false
   
#      log_build_errors('Failed Pull Image:' + base_image_name + ' from  DockerHub')
#      @last_error = ' ' + tail_of_build_log
#      return post_failed_build_clean_up
#    end
  #  true
    rescue StandardError => e
      log_build_errors(e)
      return post_failed_build_clean_up
  end
