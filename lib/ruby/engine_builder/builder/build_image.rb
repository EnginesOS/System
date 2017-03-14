

def create_engine_image
    if build_init == false
      log_build_errors('Error Build Image failed')
      @last_error = ' ' + tail_of_build_log
      return post_failed_build_clean_up
    else
      if @core_api.image_exist?(@build_params[:engine_name]) == false
        log_build_errors('Built Image not found')
        @last_error = ' ' + tail_of_build_log
        return post_failed_build_clean_up
      end
      true
    end
  rescue StandardError => e
    log_build_errors(e)
    return post_failed_build_clean_up
  end

def build_init
  log_build_output('Building Image')
  create_build_tar
  log_build_output('Cancelable:true')
  res = @core_api.docker_build_engine(@build_params[:engine_name], SystemConfig.DeploymentDir + '/' + @build_name.to_s + '.tgz', self)

  log_build_output('Cancelable:false')
  return true if res
  log_error_mesg('build Image failed ', res)
rescue StandardError => e
  log_exception(e)
end

def create_build_tar
  dest_file = SystemConfig.DeploymentDir + '/' + @build_name.to_s + '.tgz'
  cmd = ' cd ' + basedir + ' ; tar -czf ' + dest_file + ' .'
  SystemUtils.run_system(cmd)
  rescue StandardError => e
    log_build_errors(e)
    return post_failed_build_clean_up
end