module ContainerSystemStateFiles
  
  def delete_container_configs(volbuilder, c)
    cidfile = ContainerStateFiles.container_cid_file(c.store_address)
    File.delete(cidfile) if File.exist?(cidfile)
    result = volbuilder.execute_command(:remove, {target: c.container_name})
    volbuilder.wait_for('destroy', 30)
    ContainerStateFiles.remove_info_tree(c.store_address)
    SystemUtils.run_system("/opt/engines/system/scripts/system/clear_container_dir.sh #{c.container_name}")
    event_handler.trigger_engine_event(c, 'uninstalled', 'uninstalled')
    true
  end

  def save_container_log(c, options = {} )
    if c.has_container?
      unless options[:over_write] == true
        log_name = "#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.log"
      else
        log_name = 'last.log'
      end
      log_file = File.new("#{ContainerStateFiles.container_log_dir(c.store_address)}/#{log_name}", 'w+')
      begin
        unless options.key?(:max_length)
          options[:max_length] = 4096
        end
        log_file.write(
        c.logs_container(options[:max_length])        )
      ensure
        log_file.close
      end
    end
  end

end
