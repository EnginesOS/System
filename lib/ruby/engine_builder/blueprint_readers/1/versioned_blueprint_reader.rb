require_relative '../blueprint_reader.rb'
class VersionedBlueprintReader < BluePrintReader
  @schema = 1
  attr_reader   :first_run_url,
                :continuous_deployment,
                :schedules
  
  def read_scripts
    return unless @blueprint[:software].key?(:scripts)
    @custom_start_script =  @blueprint[:software][:scripts][:start][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:start)
    @custom_stop_script =  @blueprint[:software][:scripts][:shutdown][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:shutdown)
    @custom_install_script =  @blueprint[:software][:scripts][:install][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:install)
    @custom_post_install_script =  @blueprint[:software][:scripts][:post_install][:content].gsub(/\r/, '') if  @blueprint[:software][:scripts].key?(:post_install)
#    STDERR.puts('custom_start_script ' + @custom_start_script.to_s )
#    STDERR.puts('')
#    STDERR.puts('custom_stop_script' + @custom_stop_script.to_s)
#    STDERR.puts('')
#    STDERR.puts('custom_install_script' +@custom_install_script.to_s)
#    STDERR.puts('')
#    STDERR.puts('custom_post_install_script' +@custom_post_install_script.to_s )
  
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end
   
  def read_web_port_overide
    if @blueprint[:software][:base].key?(:framework_port_overide) == true
      @web_port = @blueprint[:software][:base][:framework_port_overide]
      @web_port = nil if  @web_port == 0
    end
    rescue StandardError => e
      SystemUtils.log_exception(e)
    end 
    
  def read_lang_fw_values
    log_build_output('Read Framework Settings')
    @framework = @blueprint[:software][:base][:framework]

    @runtime = @blueprint[:software][:base][:framework] # Fix me load langauge from framwork file [:language]
    @memory = @blueprint[:software][:base][:required_memory]
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
  def read_install_report_template
     @install_report_template = @blueprint[:software][:base][:installation_report]
    rescue StandardError => e
      SystemUtils.log_exception(e)
   end
   
  def read_deployment_type
     @deployment_type = @blueprint[:software][:base][:deployment_type]
    rescue StandardError => e
      SystemUtils.log_exception(e)
   end
   
   def continuous_deployment
     @continuous_deployment = @blueprint[:software][:base][:continuous_deployment]
     rescue StandardError => e
       SystemUtils.log_exception(e)
   end
   
   def first_run_url
     @first_run_url =  @blueprint[:software][:base][:first_run_url]
     rescue StandardError => e
       SystemUtils.log_exception(e)
   end
  
   
  def read_web_root
    @web_root = @blueprint[:software][:base][:web_root_directory] if @blueprint[:software][:base].key?(:web_root_directory)
    SystemDebug.debug(SystemDebug.builder,  ' @web_root ',  @web_root)
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end
  
  def blueprint_env_varaibles
     @blueprint[:software][:environment_variables]
   end
   
  def read_sql_seed
    return true unless @blueprint[:software].key?(:database_seed_file) && @blueprint[:software][:database_seed_file][:content].nil? == false
    database_seed_file = @blueprint[:software][:database_seed_file][:content]
    @database_seed = database_seed_file unless database_seed_file.nil?
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end
  
  def read_pkg_modules
     @apache_modules = []
     @pear_modules = []
     @php_modules = []
     @pecl_modules = []
     @npm_modules = []
     pkg_modules = @blueprint[:software][:required_modules]
     return true unless pkg_modules.is_a?(Array)  # not an error just nada
     pkg_modules.each do |pkg_module|
       os_package = pkg_module[:os_package]
       if os_package.nil? == false && os_package != ''
         @os_packages.push(os_package)
       end
       pkg_module_type = pkg_module[:type]
       if pkg_module_type.nil? == true
         @last_error = 'pkg Module missing type'
         return false
       end
       
       modname = pkg_module[:name]
       SystemDebug.debug(SystemDebug.builder,  ' modules  modname',  modname)
       pkg_module_type.downcase!
       if pkg_module_type == 'pear'
         @pear_modules.push(modname)
       elsif pkg_module_type == 'pecl'
         @pecl_modules.push(modname)
       elsif pkg_module_type == 'php'
         @php_modules.push(modname)
       elsif pkg_module_type == 'apache'
         @apache_modules.push(modname)
       elsif pkg_module_type == 'npm'
         @npm_modules.push(modname)
       else
         @last_error = 'pkg module_type ' + pkg_module_type + ' Unknown for ' + modname
         return false
       end
     end
     return true
    rescue StandardError => e
      SystemUtils.log_exception(e)
   end
   
#  def read_actionators
#      log_build_output('Read Actionators')
#      SystemDebug.debug(SystemDebug.builder,' readin in actionators', @blueprint[:software][:actionators])
#        STDERR.puts(' readin in actionators', @blueprint[:software][:actionators].to_s)
#      if @blueprint[:software].key?(:actionators)
#        @actionators = {}
#          @blueprint[:software][:actionators].each do |actionator |
#            @actionators[actionator[:name]] = actionator
#          end
#        STDERR.puts('Red actionators', @blueprint[:software][:actionators].to_s)
#        SystemDebug.debug(SystemDebug.builder,@actionators)
#      else
#        SystemDebug.debug(SystemDebug.builder,'No actionators')
#        @actionators = nil
#      end
#    rescue StandardError => e
#      @actionators = nil
#      SystemUtils.log_exception(e)
#    end
def read_actionators
   log_build_output('Read Actionators')
   SystemDebug.debug(SystemDebug.builder,' readin in actionators', @blueprint[:software][:actionators])
  #   STDERR.puts(' readin in actionators', @blueprint[:software][:actionators].to_s)
   if @blueprint[:software].key?(:actionators)
     @actionators = {}
       @blueprint[:software][:actionators].each do |actionator |
         @actionators[actionator[:name]] = actionator
       end
  #   STDERR.puts('Red actionators', @blueprint[:software][:actionators].to_s)
     SystemDebug.debug(SystemDebug.builder,@actionators)
   else
     SystemDebug.debug(SystemDebug.builder,'No actionators')
     @actionators = nil
   end
 rescue StandardError => e
   @actionators = nil
   SystemUtils.log_exception(e)
 end
 
 def read_schedules
   return true if @blueprint[:software][:schedules].nil?
   @schedules = @blueprint[:software][:schedules]
 end
 
def process_blueprint
  super
  read_schedules
end
    
end