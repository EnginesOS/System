def meets_physical_requirements
  check_avail_memory
  check_avail_space
  check_avail_ports
end

def check_avail_space
  log_build_output('Checking Free space')
  space = @core_api.system_image_free_space
  space /= 1024
#  SystemDebug.debug(SystemDebug.builder,  ' free space /var/lib/docker only ' + space.to_s + 'MB')
  raise EngineBuilderException.new(warning_hash('Not enough free space /var/lib/docker only ' + space.to_s + 'MB')) if space < SystemConfig.MinimumFreeImageSpace  && space != -1
  log_build_output(space.to_s + 'MB free > ' +  SystemConfig.MinimumFreeImageSpace.to_s + ' required')
end

def check_avail_memory
  free_ram = @core_api.available_ram
  if @build_params[:memory].to_i < SystemConfig.MinimumBuildRam
    ram_needed = SystemConfig.MinimumBuildRam
  else
    ram_needed = @build_params[:memory].to_i
  end
  raise EngineBuilderException.new(warning_hash('Not enough free only ' + free_ram.to_s + "MB free " + ram_needed.to_s + 'MB required')) if free_ram < ram_needed
  log_build_output(free_ram.to_s + 'MB free > ' + ram_needed.to_s + 'MB required')
end

def check_avail_ports
  unless @blueprint_reader.mapped_ports.nil?
    @blueprint_reader.mapped_ports.each_value do | mp |
      next if mp[:publicFacing] == true
      c = @core_api.is_port_available?(mp[:external])
      raise EngineBuilderException.new(warning_hash('Port Clash with ' + c + ' port:' + mp[:external].to_s)) unless c.is_a?(TrueClass)
    end
  end
end

