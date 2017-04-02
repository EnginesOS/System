module FrameworkModules
  def write_rake_list
    write_line('#Rake Actions')
    return true if @blueprint_reader.rake_actions.count == 0
    rakes = ''
    @blueprint_reader.rake_actions.each do |rake_action|
      rake_cmd = rake_action[:action]
      next if @builder.first_build == false && ! rake_action[:always_run]
      write_build_script('run_rake_task.sh ' + rake_cmd ) unless rake_cmd.nil?
    end
  end

  def write_pear_modules
    write_line('#Pear modules ')
    log_build_output('Dockerfile:Pear modules ')
    if @blueprint_reader.pear_modules.count > 0
      @blueprint_reader.pear_modules.each do |pear_mod|
        pear_mods += pear_mod + ' ' unless pear_mod.nil
      end
      write_build_script('install_pear_mods.sh  ' + pear_mods)
    end
  end

  def write_pecl_modules
    write_line('#Pecl modules ')
    log_build_output('Dockerfile:Pecl modules ')
    if @blueprint_reader.pecl_modules.count > 0
      pecl_mods = ''
      @blueprint_reader.pecl_modules.each do |pecl_mod|
        pecl_mods += pecl_mod + ' ' unless pecl_mod.nil?
      end
      write_build_script('install_pecl_mods.sh  ' + pecl_mods)
    end
    
  end

  def write_apache_modules
    return false if @blueprint_reader.apache_modules.count < 1
    write_line('#Apache Modules')
    ap_modules_str = ''
    @blueprint_reader.apache_modules.each do |ap_module|
      ap_modules_str += ap_module + ' ' unless ap_module.nil?
    end
    write_line('RUN a2enmod ' + ap_modules_str)
  
  end

  def write_npm_modules
    return if @blueprint_reader.npm_modules.count < 1
    write_line('#NPM Modules')
    npm_modules_str = ''
    @blueprint_reader.npm_modules.each do |npm_module|
      npm_modules_str += npm_module + ' ' unless npm_module.nil?
    end
    write_build_script('install_npm_modules.sh ' +  npm_modules_str)

  end
  
  def write_php_modules
    return if @blueprint_reader.php_modules.count < 1
    write_line('#PHP Modules')
    php_modules_str = ''
    @blueprint_reader.php_modules.each do |php_module|
      php_modules_str += php_module + ' ' unless php_module.nil?
    end
    write_build_script('install_php_modules.sh ' +  php_modules_str)
   
  end
end