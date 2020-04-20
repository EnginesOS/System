module ContainerApiVolumeBuilder
  def run_volume_builder(container, username, volume)
    
    clear_configs
    
    volbuilder = core.loadManagedUtility('fsconfigurator')
p = { 
  volume: volume,
  fw_user: container.cont_user_id.to_s,
  data_gid: container.data_gid.to_s,
  data_uid: container.data_uid.to_s,
  fw_uid: container.cont_user_id.to_s,
  target: container.container_name,
  target_container: container.container_name
}
STDERR.puts("VOL BUIL" * 10)
    STDERR.puts("#{p}")

     volbuilder.execute_command(:setup_engine, {
      volume: volume,
      fw_user: container.cont_user_id.to_s,
      data_gid: container.data_gid.to_s,
      data_uid: container.data_uid.to_s,
      fw_uid: container.cont_user_id.to_s,
      target: container.container_name,
      target_container: container.container_name
    })
  end

  private
    
  def clear_configs   
  fs_dir='/opt/engines/run/utilitys/fsconfigurator'
  FileUtils.mv("#{fs_dir}/running.yaml", "#{fs_dir}/running.yaml.last") if File.exist?("#{fs_dir}/running.yaml")
  FileUtils.rm("#{fs_dir}/running.yaml.bak") if File.exist?("#{fs_dir}/running.yaml.bak")
  end

end
