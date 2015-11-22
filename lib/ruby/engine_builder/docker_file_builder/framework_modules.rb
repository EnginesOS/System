module FrameworkModules
  def write_rake_list
    write_line('#Rake Actions')
    return if @blueprint_reader.rake_actions.count == 0
    rakes = ''
    @blueprint_reader.rake_actions.each do |rake_action|
      rake_cmd = rake_action[:action]
      next unless @builder.first_build == false && rake_action[:always_run]
      rakes += rake_cmd + ' ' unless rake_cmd.nil?
    end
    write_build_script('run_rake_tasks.sh ' + rakes )
  rescue Exception => e
    SystemUtils.log_exception(e)
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
  rescue Exception => e
    SystemUtils.log_exception(e)
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
  rescue Exception => e
    SystemUtils.log_exception(e)
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