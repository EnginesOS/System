class DockerApi
   attr_reader :last_error
   def create_container container
     clear_error
     begin
       commandargs = container_commandline_args(container)
       commandargs = " run  -d " + commandargs
       SystemUtils.debug_output("create cont",commandargs)
       retval = run_docker(commandargs,container)
       return retval
     rescue Exception=>e
       container.last_error=("Failed To Create ")
       SystemUtils.log_exception(e)
       return false
     end
   end

   def start_container   container
     clear_error
     begin
       commandargs =" start " + container.container_name
       return  run_docker(commandargs,container)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def stop_container container
     clear_error
     begin
       commandargs=" stop " + container.container_name
       return  run_docker(commandargs,container)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def pause_container container
     clear_error
     begin
       commandargs = " pause " + container.container_name
       return  run_docker(commandargs,container)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def   image_exists? (image_name)
     cmd= "docker images -q " + image_name
     p cmd
     res = SystemUtils.run_command(cmd)

     if res.length >0
       return true
     else
       return false
     end

   end

   def unpause_container container
     clear_error
     begin
       commandargs=" unpause " + container.container_name
       return  run_docker(commandargs,container)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def ps_container container
     clear_error
     begin
       commandargs="docker top " + container.container_name + " axl"
        if run_docker("top",container) == true
          return   container.last
        else
          return   container.last_error
        end
          
       #SystemUtils.run_system(commandargs)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def signal_container_process(pid,signal,container)
     clear_error
     commandargs=" exec " + container.container_name + " kill -" + signal + " " + pid.to_s
     return  run_docker(commandargs,container)
   rescue  Exception=>e
     SystemUtils.log_exception(e)
     return false
   end

   def logs_container container
     clear_error
     begin
       commandargs="docker logs " + container.container_name
       return  SystemUtils.run_system(commandargs)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def inspect_container container
     clear_error
     begin
       commandargs=" inspect " + container.container_name
       return  run_docker(commandargs,container)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def destroy_container container
     clear_error
     begin
       commandargs= " rm " +   container.container_name
       ret_val = run_docker(commandargs,container)
     rescue Exception=>e
       container.last_error=( "Failed To Destroy " + e.to_s)
       SystemUtils.log_exception(e)

       return false
     end
   end

   def delete_image container
     clear_error
     begin
       commandargs= " rmi " +   container.image
       ret_val =  run_docker(commandargs,container)
        if ret_val == true
          clean_up_dangling_images
        end
       return ret_val
     rescue Exception=>e
       container.last_error=( "Failed To Delete " + e.to_s)
       SystemUtils.log_exception(e)
       return false
     end
   end

   def docker_exec(container,command,args)
     run_args = "exec " + container.container_name + " " + command + " " + args
     
     return run_docker(run_args,container)
   end
   
   def run_docker (args,container)
     clear_error
     require 'open3'
     SystemUtils.debug_output("Run docker",args)
     res = String.new
     error_mesg = String.new
     begin
       container.last_result=(  "")
       Open3.popen3("docker " + args ) do |stdin, stdout, stderr, th|
         oline = String.new
         stderr_is_open=true
         begin
           stdout.each do |line|
             line = line.gsub(/\\\"/,"")
             oline = line
             res += line.chop
             #              p :lne_by_line
             #              p line
             if stderr_is_open
               error_mesg += stderr.read_nonblock(256)
             end
           end
           
         rescue Errno::EIO
           res += oline.chop
           SystemUtils.debug_output("read stderr",oline)
           error_mesg += stderr.read_nonblock(256)
         rescue  IO::WaitReadable
           retry
         rescue EOFError
           if stdout.closed? == false
             stderr_is_open = false
             retry
           elsif stderr.closed? == false
             error_mesg += stderr.read_nonblock(1000)
             container.last_result=(  res)
             container.last_error=( error_mesgs)
           else
             container.last_result=(  res)
             container.last_error=( error_mesgs)
           end
         end
         @last_error=error_mesg
         if error_mesg.include?("Error")
           container.last_error=(error_mesg)

           return false
         else
           container.last_error=("")
         end
         #
         #          if res.start_with?("[") == true
         #            res = res +"]"
         #          end
         if res != nil && res.end_with?(']') == false
           res+=']'
         end

         container.last_result=(res)
         return true
       end
     rescue Exception=>e
       @last_error=error_mesg + e.to_s
       container.last_result=(res)
       container.last_error=(error_mesg + e.to_s)
       SystemUtils.log_exception(e)
       return false
     end

     return true
   end

   def get_envionment_options(container)
     e_option =String.new
     if(container.environments && container.environments != nil)
       container.environments.each do |environment|
         if environment != nil && environment.name != nil  && environment.value != nil 
           environment.value.gsub!(/ /,"\\ ")
           e_option = e_option + " -e " + environment.name + "="  + environment.value 
         end
       end
     end
     return e_option
   rescue Exception=>e
     SystemUtils.log_exception(e)
     return e.to_s
   end

   def get_port_options(container)
     eportoption = String.new
     if(container.eports )
       container.eports.each do |eport|
         if eport != nil 
           eportoption = eportoption +  " -p "
           if eport.external != nil && eport.external  >0
             eportoption = eportoption + eport.external.to_s + ":"
           end
           eportoption = eportoption + eport.port.to_s
           if eport.proto_type == nil
             eport.proto_type=('tcp')
           end
           eportoption = eportoption + "/"+ eport.proto_type + " "
         end
       end
     end
     return eportoption
   rescue Exception=>e
     SystemUtils.log_exception(e)
     return e.to_s
   end

   def container_commandline_args(container)
     clear_error
     begin
       envionment_options = get_envionment_options( container)
       port_options = get_port_options( container)
       volume_option = get_volume_option( container)
       if volume_option == false || envionment_options == false || port_options == false
         return false
       end
       if container.conf_self_start == false
         start_cmd=" /bin/bash /home/init.sh"
       else
         start_cmd=" "
       end
       commandargs =  "-h " + container.hostname + \
       envionment_options + \
       " --memory=" + container.memory.to_s + "m " +\
       volume_option + " " +\
       port_options +\
       " --cidfile " + SysConfig.CidDir + "/" + container.container_name + ".cid " +\
       "--name " + container.container_name + \
       "  -t " + container.image + " " +\
       start_cmd

       return commandargs
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return e.to_s
     end
   end

   def get_volume_option(container)
     clear_error
     begin
       #System
       volume_option = SysConfig.timeZone_fileMapping #latter this will be customised
       volume_option += " -v " + container_state_dir(container) + "/run:/engines/var/run:rw "
       # if container.ctype == "service"
       #  volume_option += " -v " + container_log_dir(container) + ":/var/log:rw "
       incontainer_logdir = get_container_logdir(container)
       volume_option += " -v " + container_log_dir(container) + ":/" + incontainer_logdir + ":rw "
       if incontainer_logdir !="/var/log" && incontainer_logdir !="/var/log/"
         volume_option += " -v " + container_log_dir(container) + "/vlog:/var/log/:rw"
       end
       #end
       #container specific
       if container.volumes  
         container.volumes.each_value do |volume|
           if volume !=nil
             if volume.localpath !=nil
               volume_option = volume_option.to_s + " -v " + volume.localpath.to_s + ":/" + volume.remotepath.to_s +  ":" + volume.mapping_permissions.to_s
             end
           end
         end
       end
       return volume_option
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def get_container_logdir(container)
     clear_error
     if container.framework == nil || container.framework.length ==0
       return "/var/log"
     end

     container_logdetails_file_name = false

     framework_logdetails_file_name =  SysConfig.DeploymentTemplates + "/" + container.framework + "/home/LOG_DIR"
     SystemUtils.debug_output("Frame logs details",framework_logdetails_file_name)

     if File.exists?(framework_logdetails_file_name )
       container_logdetails_file_name = framework_logdetails_file_name
     else
       container_logdetails_file_name = SysConfig.DeploymentTemplates + "/global/home/LOG_DIR"
     end
     SystemUtils.debug_output("Container log details",container_logdetails_file_name)
     begin
       container_logdetails = File.read(container_logdetails_file_name)
     rescue
       container_logdetails = "/var/log"
     end

     return container_logdetails
   rescue Exception=>e
     SystemUtils.log_exception(e)

     return false
   end

   def clean_up_dangling_images
   
  cmd = "docker rmi $( docker images -f \"dangling=true\" -q)"
     SystemUtils.run_system(cmd)
   end
   
   protected

   def container_state_dir(container)
     return SysConfig.CidDir + "/"  + container.ctype + "s/" + container.container_name
   end

   def container_log_dir container
     return SysConfig.SystemLogRoot + "/"  + container.ctype + "s/" + container.container_name
   end

   def clear_error
     @last_error = ""
   end

   
   
   
 end#END of DockerApi