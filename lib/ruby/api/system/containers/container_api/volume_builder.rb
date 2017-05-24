module ContainerApiVolumeBuilder
  def run_volume_builder(container, username)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    result = volbuilder.execute_command(:setup_engine, {
    volume: '/',
    fw_user: username.to_s,
    target: container.container_name,
    target_container: container.container_name,
    data_gid: container.data_gid.to_s
  })
    raise EngineBuilderException.new(error_hash('volbuild problem ' + result.to_s, result)) unless result[:result] == 0
  end
end