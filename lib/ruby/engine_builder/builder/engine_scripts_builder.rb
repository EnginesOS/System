module EngineScriptsBuilder
  
  def create_scripts
     FileUtils.mkdir_p(basedir + SystemConfig.ScriptsDir)
     create_start_script
    create_stop_script
     create_install_script
     create_post_install_script
     write_worker_commands
     create_actionator_scripts
     configure_services_backup(@service_builder.attached_services)
    
  rescue Exception => e
    SystemUtils.log_exception(e)
   end
 
   def create_start_script
     if @blueprint_reader.custom_start_script
       write_software_script_file(SystemConfig.StartScript, @blueprint_reader.custom_start_script)
      
     end
   rescue Exception => e
     SystemUtils.log_exception(e)
   end

  def create_stop_script
    if @blueprint_reader.custom_start_script
      write_software_script_file(SystemConfig.StopScript, @blueprint_reader.custom_start_script)
     
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end
   def create_install_script
     if @blueprint_reader.custom_install_script
       write_software_script_file(SystemConfig.InstallScript,  @blueprint_reader.custom_install_script)      
     end
   rescue Exception => e
     SystemUtils.log_exception(e)
   end
 
   def create_post_install_script
 
     if @blueprint_reader.custom_post_install_script
       write_software_script_file(SystemConfig.PostInstallScript, @blueprint_reader.custom_post_install_script)
      
       @has_post_install = true
     end
     rescue Exception => e
          SystemUtils.log_exception(e)
   end
  
  def create_actionator_scripts
    
    SystemDebug.debug(SystemDebug.builder| SystemDebug.actions,"creating actionators ",@blueprint_reader.actionators)
    log_build_output('Creating Actionators')
    return true if @blueprint_reader.actionators.nil?
    destdir = SystemConfig.ActionatorDir
    FileUtils.mkdir_p(basedir + destdir ) unless Dir.exist?(basedir + destdir )
    
    @blueprint_reader.actionators.keys.each do | key|
      actionator = @blueprint_reader.actionators[key] 
      SystemDebug.debug(SystemDebug.builder| SystemDebug.actions,'create actionator', actionator)
      filename = SystemConfig.ActionatorDir + '/' + actionator[:name] + '.sh'
      SystemDebug.debug(SystemDebug.builder| SystemDebug.actions,"creating actionator " ,  actionator[:name],filename)

     if @blueprint_reader.schema == 0
       write_software_script_file(filename, actionator[:script])
     else 
       write_software_script_file(filename, actionator[:script][:content])
     end
      
    end
    return true
    rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
  def write_worker_commands
     log_build_output('Dockerfile:Worker Commands')
     scripts_path =  '/home/engines/scripts/'
     if Dir.exist?(scripts_path) == false
       FileUtils.mkdir_p(scripts_path)
     end
     if @blueprint_reader.worker_commands.nil? == false && @blueprint_reader.worker_commands.length > 0
       content = "#!/bin/bash\n"
       content += "cd /home/app\n"
       @blueprint_reader.worker_commands.each do |command|
         content += command + "\n"
       end
       write_software_script_file(scripts_path + 'pre-running.sh', content)
    
     end
 
     return true if @blueprint_reader.blocking_worker.nil?
 
     content = "#!/bin/bash\n"
     content += "cd /home/app\n"
     content += @blueprint_reader.blocking_worker.to_s
     content += "\n"
    write_software_script_file(scripts_path + 'blocking.sh', content)
    # File.chmod(0755, basedir + scripts_path + 'blocking.sh')
 
   rescue Exception => e
     SystemUtils.log_exception(e)
   end
   
   private
   
   def write_software_script_file(scripts_path,content)
     write_software_file(scripts_path, content)
     File.chmod(0755, basedir + scripts_path )
     rescue Exception => e
          SystemUtils.log_exception(e)
   end

end