module SaveEngineConfiguration
  def save_engine_built_configuration(mc)
    write_actionators(mc , @blueprint_reader.actionators)
    write_schedules(mc, @blueprint_reader.schedules) if @blueprint_reader.respond_to?(:schedules)
    write_services(mc.store_address, service_builder.attached_services)
    write_variables(mc.store_address, @blueprint_reader.environments)
    mc.store.set_container_icon_url(mc.container_name , @build_params[:icon_url]) unless @build_params[:icon_url].nil?
  end

  private

  def write_schedules(c, schedules)
    unless schedules.nil?
      FileUtils.mkdir_p(c.store.schedules_dir(c.container_name)) unless Dir.exist?(c.store.schedules_dir(c.container_name))
      serialized_object = YAML.dump(schedules)
      f = File.new(c.store.schedules_file(c.container_name), File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.write(serialized_object)
        f.flush()
      ensure
        f.close
      end
    end
  end

  def write_actionators(c, actionators)
    unless actionators.nil?
      FileUtils.mkdir_p(c.store.actionator_dir(c.container_name)) unless Dir.exist?(c.store.actionator_dir(c.container_name))
      serialized_object = YAML.dump(actionators)
      f = File.new("#{c.store.actionator_dir(c.container_name)}/actionators.yaml", File::CREAT | File::TRUNC | File::RDWR, 0644)
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