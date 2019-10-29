module SaveEngineConfiguration
  def save_engine_built_configuration(mc)
    write_actionators(mc.store_address , @blueprint_reader.actionators)
    write_schedules(mc.store_address, @blueprint_reader.schedules) if @blueprint_reader.respond_to?(:schedules)
    write_services(mc.store_address, service_builder.attached_services)
    write_variables(mc.store_address, @blueprint_reader.environments)
    SystemPreferences.set_container_icon_url(mc.store_address , @build_params[:icon_url]) unless @build_params[:icon_url].nil?
  end

  private

  def write_schedules(ca, schedules)
    unless schedules.nil?
      FileUtils.mkdir_p(ContainerStateFiles.schedules_dir(ca)) unless Dir.exist?(ContainerStateFiles.schedules_dir(ca))
      serialized_object = YAML.dump(schedules)
      f = File.new(ContainerStateFiles.schedules_file(ca), File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.write(serialized_object)
        f.flush()
      ensure
        f.close
      end
    end
  end

  def write_actionators(ca, actionators)
    unless actionators.nil?
      FileUtils.mkdir_p(ContainerStateFiles.actionator_dir(ca)) unless Dir.exist?(ContainerStateFiles.actionator_dir(ca))
      serialized_object = YAML.dump(actionators)
      f = File.new("#{ContainerStateFiles.actionator_dir(ca)}/actionators.yaml", File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.write(serialized_object)
        f.flush()
      ensure
        f.close
      end
    end
  end

  def write_services(ca, attached_services)
  end

  def write_variables(ca, environments)
  end

end