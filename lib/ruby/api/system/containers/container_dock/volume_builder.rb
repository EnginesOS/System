module ContainerDockVolumeBuilder
  def run_volume_builder(container, username, volume)
    volbuilder = core.loadManagedUtility('fsconfigurator')
details =  {
          volume: volume,
          fw_user: container.cont_user_id.to_s,
          data_gid: container.data_gid.to_s,
          data_uid: container.data_uid.to_s,
          fw_uid: container.cont_user_id.to_s,
          target: container.container_name,
          target_container: container.container_name
        }
        
        STDERR.puts("volbuilder #{details}")
     volbuilder.execute_command(:setup_engine, details)
  end
end
