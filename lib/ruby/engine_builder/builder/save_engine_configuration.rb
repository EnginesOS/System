module SaveEngineConfiguration
   def save_engine_configuration
   
  write_actionators(@blueprint_reader.actionators)
  write_services
  write_variables
  
  
end

def write_actionators(actionators)
  return true if actionators.nil?
  FileUtils.mkdir_p(ContainerStateFiles.actionator_dir(@mc)) unless Dir.exist?(ContainerStateFiles.actionator_dir(@mc))
  serialized_object = YAML.dump(actionators)
  
  f = File.new(ContainerStateFiles.actionator_dir(@mc) + '/actionators.yaml', File::CREAT | File::TRUNC | File::RDWR, 0644)
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