module ContainerApiVolumeBuilder
  def run_volume_builder(container, username, volume)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    result = volbuilder.execute_command(:setup_engine, {
      volume: volume,
      fw_user: username.to_s,
      target: container.container_name,
      target_container: container.container_name,
      data_gid: container.data_gid.to_s
    }) 
#    STDERR.puts('Wait for create ' + volbuilder.container_name + ' is in ' + volbuilder.status.to_s)
#    volbuilder.wait_for('create', 10)
#    STDERR.puts('Wait for start ' + volbuilder.container_name + ' is in ' + volbuilder.status.to_s)
#    volbuilder.wait_for('start', 10)
#    STDERR.puts('Wait for stop ' + volbuilder.container_name + ' is in ' + volbuilder.status.to_s)
#    volbuilder.wait_for('stop', 90)
#    STDERR.puts('Stopped ' + volbuilder.container_name + ' is in ' + volbuilder.status.to_s)
#    volbuilder.destroy_container
    raise EngineBuilderException.new(error_hash('volbuild problem ' + result.to_s, result)) unless result[:result] == 0
  end
end