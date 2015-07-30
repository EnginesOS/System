class BluePrintReader

  def initialize(build_name,contname,blue_print,builder)
     @build_name = build_name

     @data_uid="11111"
     @data_gid="11111"
     @builder=builder
     @container_name = contname
     @blueprint = blue_print
     @web_port=nil
     @services = Array.new
     @os_packages = Array.new

   end

   attr_reader :persistant_files,
               :persistant_dirs,
               :last_error,
               :workerPorts,
               :environments,
               :recursive_chmods,
               :single_chmods,
               :framework,
               :runtime,
               :memory,
               :rake_actions,
               :os_packages,
               :pear_modules,
               :apache_modules,
               :php_modules,
               :pecl_modules,
               :archives_details,
               :worker_commands,
               :cron_jobs,
               :sed_strings,
               :volumes,
               :databases,
               :data_uid,
               :data_gid,
               :cron_job_list,
               :web_port,
               :services,
               :deployment_type

   def  log_build_output(line)
     @builder.log_build_output(line)
   end

   def log_build_errors(line)
     @builder.log_build_errors(line)
   end

   def clean_path(path)
     #FIXME remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any " " or ";" or "&" or "|" etc
     return path
   end

   def get_basedir
     return SysConfig.DeploymentDir + "/" + @build_name
   end

 
   def process_blueprint
     begin
       log_build_output("Process BluePrint")
       read_services
       read_environment_variables
      
       read_os_packages
       read_lang_fw_values
    
       read_pkg_modules
       read_app_packages
   
       read_write_permissions_recursive
       read_write_permissions_single
       read_worker_commands
       read_deployment_type
#        read_cron_jobs
       read_sed_strings
       read_work_ports
       read_os_packages
       read_app_packages
       read_rake_list
       read_persistant_files
       read_persistant_dirs
       read_web_port_overide
     rescue Exception=>e
       SystemUtils.log_exception(e)
     end

   end
  def read_deployment_type
    @deployment_type = @blueprint[:software][:deployment_type] 
  end
  def re_set_service(service_cnt,service_hash)
    @services[service_cnt] = service_hash
    #services[service_cnt]=service_hash
  end

   def read_web_port_overide
     if @blueprint[:software].has_key?(:framework_port_overide) == true
       @web_port=@blueprint[:software][:framework_port_overide]
     end
   end

   def read_persistant_dirs
     begin
       log_build_output("Read Persistant Dirs")

       @persistant_dirs = Array.new

       pds =   @blueprint[:software][:persistent_directories]
                                 
       if pds.is_a?(Array) == false
                     return true #not an error just nada
              end
       pds.each do |dir|
         @persistant_dirs.push(dir[:path])

       end

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_persistant_files
     begin
       log_build_output("Read Persistant Files")

       @persistant_files = Hash.new
       src_paths = Array.new
       dest_paths = Array.new

       pfs =   @blueprint[:software][:persistent_files]
       if pfs.is_a?(Array) == false
                     return true #not an error just nada
              end
       files= String.new
       pfs.each do |file|
         path = clean_path(file[:path])
         #link_src = path.sub(/app/,"")
         src_paths.push(path)
       end
       p :src_paths
       p src_paths
       p :dest_paths
       p dest_paths

       @persistant_files[:src_paths]= src_paths

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_rake_list
     begin
       @rake_actions = Array.new
       log_build_output("Read Rake List")
       rake_cmds = @blueprint[:software][:rake_tasks]
       if rake_cmds.is_a?(Array) == false
                     return true #not an error just nada
              end

       rake_cmds.each do |rake_cmd|
           @rake_actions.push(rake_cmd)         
       end

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_services

     @databases=Array.new
     @volumes=Hash.new

     
     log_build_output("Read Services")
     services=@blueprint[:software][:service_configurations]
     if services.is_a?(Array) == false
                   return true #not an error just nada
            end
     services.each do |service|
       if service.has_key?(:publisher_namespace) == false || service[:publisher_namespace] == nil
         service[:publisher_namespace] = "EnginesSystem"  
       end
       service[:service_type]=service[:type_path]          
       p :service_provider
       p   service[:publisher_namespace] 
       p :servicetype_name
       p service[:type_path]
       add_service(service)
          
     end
   end #FIXME

   def add_service (service_hash)
     p :add_service
     p service_hash
     @builder.templater.fill_in_dynamic_vars(service_hash)
     if service_hash[:type_path] == "filesystem/local/filesystem"
       add_file_service(service_hash[:variables][:name],service_hash[:variables][:engine_path])
     end
     @services.push(service_hash)
   end

   def add_file_service(name,dest) #FIXME and put me in coreapi
     begin
       log_build_output("Add File Service " + name)
       if dest == nil || dest == ""
         dest=name
       end
       if(dest.start_with?("/home/app/") == false )
         if(dest.start_with?("/home/fs/") == false)
           if dest != "/home/app"
             p :dest
             p "_" + dest + "_"
             dest="/home/fs/" + dest
           end
         end
       elsif dest== "/home/fs/" ||  dest== "/home/fs"
         @builder.app_is_persistant=true
         
       end
       permissions = PermissionRights.new(@container_name,"","")
       vol=Volume.new(name,SysConfig.LocalFSVolHome + "/" + @container_name + "/" + name,dest,"rw",permissions)
       @volumes[name]=vol

     rescue Exception=>e
       p name
       p dest
       p @container_name
     SystemUtils.log_exception(e)
       return false
     end
   end


   def read_os_packages
     begin
     
       log_build_output("Read OS Packages")
       ospackages = @blueprint[:software][:system_packages]
         
       if ospackages.is_a?(Array) == false
                     return true #not an error just nada
              end
         
       ospackages.each do |package|
         @os_packages.push(package[:package])
       end
       
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_lang_fw_values
     log_build_output("Read Framework Settings")
     begin
       @framework = @blueprint[:software][:framework]
       p @framework
       @runtime =  @blueprint[:software][:language]
       @memory =  @blueprint[:software][:required_memory]

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

#   def read_pear_list
#     begin
#       @pear_modules = Array.new
#
#       log_build_output("Read Pear List")
#       pear_mods = @blueprint[:software][:pear_modules]
#       
#         if pear_mods == nil || pear_mods.length == 0
#           log_build_output("no pear")
#         return
#         end
#           log_build_output(pear_mods.length.to_s + "Pears")
#         pear_mods.each do |pear_mod|
#           p :Pear_mod
#           p pear_mod
#           log_build_output(pear_mod.to_s)
#           mod =  pear_mod[:module]
#         os_package = pear_mod[:os_package]
#                if os_package != nil && os_package != ""
#                @os_packages.push(os_package)
#                end
#           if mod !=nil
#             @pear_modules.push(mod)
#             p :added_pear
#             p mod
#           end
#       end
#   end
#     rescue Exception=>e
#     SystemUtils.log_exception(e)
#       return false
#   end
#   
   def read_pkg_modules
     

     @apache_modules = Array.new
     @pear_modules = Array.new
     @php_modules = Array.new
     @pecl_modules = Array.new
     
     pkg_modules =  @blueprint[:software][:modules]
     if pkg_modules.is_a?(Array) == false
                   return true #not an error just nada
            end
         pkg_modules.each do |pkg_module |
           os_package = pkg_module[:os_package]
                   if os_package != nil && os_package != ""
                    @os_packages.push(os_package)
                   end
               pkg_module_type =  pkg_module[:module_type]
                 if    pkg_module_type == nil
                   @last_error="pkg Module missing module_type"
                   return false
                 end
                 modname = pkg_module[:module_name]
                   
               if   pkg_module_type == "pear"
                 @pear_modules.push(modname)
               elsif pkg_module_type == "pecl"
                 @pecl_modules.push(modname)
               elsif pkg_module_type == "php"
                   @php_modules.push(modname)
               elsif pkg_module_type == "apache"
                 @apache_modules.push(modname)
               else
                  @last_error="pkg module_type " + pkg_module_type + " Unknown for " +  modname 
                  return false
               end
         end
      return true
   end

#   def read_apache_modules
#     @apache_modules = Array.new
#     log_build_output("Read Apache Modules List")
#     mods =  @blueprint[:software][:apache_modules]
#     if mods == nil
#       p :no_apache_modules
#       return true
#     end
#     mods.each do |ap_module|
#       mod = ap_module[:module]
#       os_package = ap_module[:os_package]
#         if os_package != nil && os_package != ""
#         @os_packages.push(os_package)
#         end
#       if mod != nil
#         @apache_modules.push(mod)
#         p :Add_apache
#         p mod
#       end
#     end
#     return true
#   rescue Exception=>e
#SystemUtils.log_exception(e)
#     return false
#   end

   def read_app_packages
     begin
       log_build_output("Read App Packages ")
       @archives_details = Array.new

       log_build_output("Configuring install Environment")
       archives = @blueprint[:software][:installed_packages]
       n=0
       if archives.is_a?(Array) == false
               return true #not an error just nada
             end

       
       archives.each do |archive|
         archive_details = Hash.new
         arc_src=clean_path(archive[:source_url])
         arc_name=clean_path(archive[:name])
         arc_loc =clean_path(archive[:destination])
         arc_extract=clean_path(archive[:extraction_command])
         arc_dir=clean_path(archive[:path_to_extracted])

         if arc_loc == "./"
           arc_loc=""
         elsif arc_loc.end_with?("/")
           arc_loc = arc_loc.chop() #note not String#chop
         end
         archive_details[:source_url]=arc_src
         archive_details[:package_name]=arc_name
         archive_details[:extraction_command]=arc_extract
         archive_details[:destination]=arc_loc
         archive_details[:path_to_extracted]=arc_dir
           p :read_in_arc_details
           p archive_details
         @archives_details.push(archive_details)
       end

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_write_permissions_recursive
     begin
       log_build_output("Read Recursive Write Permissions")
       @recursive_chmods = Array.new
       log_build_output("set permissions recussive")
       chmods = @blueprint[:software][:file_write_permissions]
       p :Single_Chmods
       if chmods.is_a?(Array) == false
               return true #not an error just nada
        end
         chmods.each do |chmod |
           p chmod
           if chmod[:recursive]==true
             directory = clean_path(chmod[:path])
             p directory
             @recursive_chmods.push(directory)
           end       
         #FIXME need to strip any ../ and any preceeding ./ in clean_path         
       end
       return true
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_write_permissions_single
     begin
       log_build_output("Read Non-Recursive Write Permissions")
       @single_chmods =Array.new
       log_build_output("set permissions  single")
       chmods = @blueprint[:software][:file_write_permissions]
       p :Recursive_Chmods
       if chmods.is_a?(Array) == false
                    return true #not an error just nada
                  end
         chmods.each do |chmod |
           p chmod
           if chmod[:recursive]==false
             p chmod[:path]
             directory = clean_path(chmod[:path])
             @single_chmods.push(directory)
           end
         end
       
       return true

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_worker_commands
     begin

       log_build_output("Read Workers")
       @worker_commands = Array.new
       workers =@blueprint[:software][:workers]
       if workers.is_a?(Array) == false
         return true #not an error just nada
       end
       workers.each do |worker|
         @worker_commands.push(worker[:command])
       end
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end



   def read_sed_strings
     begin
       log_build_output("Read Sed Strings")
       @sed_strings = Hash.new
       @sed_strings[:src_file] = Array.new
       @sed_strings[:dest_file] = Array.new
       @sed_strings[:sed_str] = Array.new
       @sed_strings[:tmp_file] = Array.new

       log_build_output("set sed strings")
       seds=@blueprint[:software][:replacement_strings]
       if seds.is_a?(Array) == false
                    return true #not an error just nada
                  end

       n=0
       seds.each do |sed|

         file = clean_path(sed[:file])
         dest = clean_path(sed[:destination])
         tmp_file = "/tmp/" + File.basename(file) + "." + n.to_s
         if file.match(/^_TEMPLATES.*/) != nil
           template_file = file.gsub(/^_TEMPLATES/,"")
         else
           template_file = nil
         end

         if  template_file != nil
           src_file = "/home/engines/templates/" +  template_file

         else
           src_file = "/home/app/" +  file
         end
         dest_file = "/home/app/" +  dest
         sedstr = sed[:replacement_string]
         @sed_strings[:src_file].push(src_file)
         @sed_strings[:dest_file].push(dest_file)
         @sed_strings[:tmp_file].push(tmp_file)
         @sed_strings[:sed_str].push(sedstr)

         n=n+1
       end

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_work_ports
     begin
       @workerPorts = Array.new
       log_build_output("Read Work Ports")
       ports =  @blueprint[:software][:worker_ports]
       puts("Ports Json" + ports.to_s)
       if ports.is_a?(Array) == false
                     return true #not an error just nada
              end
         ports.each do |port|
           portnum = port[:port]
           name = port[:name]
           external = port['external']
           type = port['protocol']
           if type == nil
             type='tcp'
           end
           #FIX ME when public ports supported
           puts "Port " + portnum.to_s + ":" + external.to_s
           @workerPorts.push(WorkPort.new(name,portnum,external,false,type))
         end

       return true
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def read_environment_variables
     log_build_output("Read Environment Variables")
     @environments = Array.new
     p :set_environment_variables
     p @builder.set_environments
     begin
       envs = @blueprint[:software][:variables]
       if envs.is_a?(Array) == false
                     return true #not an error just nada
              end
       envs.each do |env|
         p env
         name=env[:name]
         value=env[:value]
         ask=env[:ask_at_build_time]
         mandatory = env[:mandatory]
         build_time_only =  env[:build_time_only]
         label =  env[:label]
         immutable =  env[:immutable]
         lookup_system_values = env[:lookup_system_values]
           
         if @builder.set_environments != nil
           p :looking_for_
           p name
           if ask == true  && @builder.set_environments.has_key?(name) == true              
             entered_value=@builder.set_environments[name]
              if entered_value != nil && entered_value.length !=0#FIXme needs to be removed
                value = entered_value 
              end
           end
         end
         name.sub!(/ /,"_")
         p :name_and_value
         p name
         p value
         ev = EnvironmentVariable.new(name,value,ask,mandatory,build_time_only,label,immutable)
         p ev
         @environments.push(ev)
       end
     rescue Exception=>e
     SystemUtils.log_exception(e)
       return false
     end
   end
 end