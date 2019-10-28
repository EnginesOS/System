module ContainerActionators
  def get_service_actionator(container, action)
     actionators = load_service_actionators(container)
     # STDERR.puts(' ACITONATORS ' + actionators.to_s)
     # STDERR.puts('LOOKING 4 ' + action.to_s)
     # STDERR.puts('is it ' + actionators[action.to_sym].to_s)
     actionators[action.to_sym]
   end
 
   def load_service_actionators(container)
     #    SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
     #    if File.exist?(actionator_dir(container) + '/actionators.yaml')
     #      yaml = File.read(actionator_dir(container) + '/actionators.yaml')
     #      actionators = YAML::load(yaml)
     #      SystemDebug.debug(SystemDebug.actions, container, actionators)
     #      actionators if actionators.is_a?(Hash)
     #    else
     #      {}
     #    end
     SoftwareServiceDefinition.actionators({
       type_path: container.type_path, publisher_namespace: container. publisher_namespace })
   end
 
   def get_engine_actionator(container, action)
     actionators = load_engine_actionators(container)
     #    SystemDebug.debug(SystemDebug.actions, container, actionators[action]) #.to_sym])
     #  STDERR.puts('ACRTION ' + action.to_s)
     actionators[action]
   end
 
   def load_engine_actionators(container)
     #   SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
     if File.exist?("#{actionator_dir(container)}/actionators.yaml")
       yaml = File.read("#{actionator_dir(container)}/actionators.yaml")
       actionators = YAML::load(yaml)
       #     SystemDebug.debug(SystemDebug.actions,container ,actionators)
       actionators if actionators.is_a?(Hash)
     else
       {}
     end
   end
   

def write_actionators(container, actionators)
  unless actionators.nil?
    Dir.mkdir_p(actionator_dir(container)) unless Dir.exist?(actionator_dir(container))
    serialized_object = YAML.dump(actionators)
    f = File.new("#{actionator_dir(container)}/actionators.yaml", File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.puts(serialized_object)
      f.flush()
    ensure
      f.close
    end
  end
end
end
