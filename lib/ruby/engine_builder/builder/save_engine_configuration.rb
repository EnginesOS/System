module SaveEngineConfiguration
   def save_engine_configuration
   
  write_actionators(@mc, @blueprint_reader.actionators)
  write_services(@mc, @blueprint_reader.attached_services)
  write_variables(@mc, @blueprint_reader.actionators)
  
  
end

def write_actionators(container, actionators)
  return true if actionators.nil?
  FileUtils.mkdir_p(ContainerStateFiles.actionator_dir(container)) unless Dir.exist?(ContainerStateFiles.actionator_dir(container))
  serialized_object = YAML.dump(actionators)
  
  f = File.new(ContainerStateFiles.actionator_dir(container) + '/actionators.yaml', File::CREAT | File::TRUNC | File::RDWR, 0644)
      f.puts(serialized_object)
      f.flush()
      f.close
rescue StandardError => e
  log_exception(e)
end


 def  write_services
   
   
   
 end
 
 def write_variables
 end

end