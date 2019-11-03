def create_engine_image
  build_init
  if core.image_exist?(@build_params[:engine_name]) == false
    raise EngineBuilderException.new(error_hash('Built Image not found'))
  end
end

def build_init
  log_build_output('Building Image')
  create_build_tar
  log_build_output('Cancelable:true')
  core.docker_build_engine(@build_params[:engine_name], "#{SystemConfig.DeploymentDir}/#{@build_name}.tgz")
  log_build_output('Cancelable:false')
end

private

def create_build_tar
  dest_file = "#{SystemConfig.DeploymentDir}/#{@build_name}.tgz"
cmd = "cd #{basedir}; tar -czf #{dest_file} ."
  SystemUtils.run_system(cmd)
end
