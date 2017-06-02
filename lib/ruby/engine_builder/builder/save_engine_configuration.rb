module SaveEngineConfiguration
  def save_engine_built_configuration(mc)
    write_actionators(mc, @blueprint_reader.actionators)
    write_schedules(mc, @blueprint_reader.schedules) if @blueprint_reader.respond_to?(:schedules)
    write_services(mc, @service_builder.attached_services)
    write_variables(mc, @blueprint_reader.environments)
  end

  def write_schedules(container, schedules)
    return true if schedules.nil?
    FileUtils.mkdir_p(ContainerStateFiles.schedules_dir(container)) unless Dir.exist?(ContainerStateFiles.schedules_dir(container))
    serialized_object = YAML.dump(schedules)
    f = File.new(ContainerStateFiles.schedules_file(container), File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.flush()
    f.close
  end

  def write_actionators(container, actionators)
    return true if actionators.nil?
    FileUtils.mkdir_p(ContainerStateFiles.actionator_dir(container)) unless Dir.exist?(ContainerStateFiles.actionator_dir(container))
    serialized_object = YAML.dump(actionators)

    f = File.new(ContainerStateFiles.actionator_dir(container) + '/actionators.yaml', File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.flush()
    f.close
  end

  def  write_services(mc, attached_services)
  end

  def write_variables(mc, environments)
  end

end