require_relative '../blueprint_reader.rb'
class VersionedBlueprintReader < BluePrintReader

  attr_reader   :first_run_url,
                :continuous_deployment
  
  def read_scripts
    return unless @blueprint[:software].key?(:scripts)
    @custom_start_script =  @blueprint[:software][:scripts][:start].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:start)
    @custom_stop_script =  @blueprint[:software][:scripts][:shutdown].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:shutdown)
    @custom_install_script =  @blueprint[:software][:install].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:install)
    @custom_post_install_script =  @blueprint[:software][:scripts][:post_install].gsub(/\r/, '') if  @blueprint[:software][:scripts].key?(:post_install)
  end
   
  def read_web_port_overide
    if @blueprint[:software][:base].key?(:framework_port_overide) == true
      @web_port = @blueprint[:software][:base][:framework_port_overide]
      @web_port = nil if  @web_port == 0
    end
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
   end
   
  def read_deployment_type
     @deployment_type = @blueprint[:software][:base][:deployment_type]
   end
   
   def continuous_deployment
     @continuous_deployment = @blueprint[:software][:base][:continuous_deployment]
   end
   
   def first_run_url
     @first_run_url =  @blueprint[:software][:base][:first_run_url]
   end
  
   
  def read_web_root
    @web_root = @blueprint[:software][:base][:web_root_directory] if @blueprint[:software].key?(:web_root_directory)
    SystemDebug.debug(SystemDebug.builder,  ' @web_root ',  @web_root)
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
   end
end