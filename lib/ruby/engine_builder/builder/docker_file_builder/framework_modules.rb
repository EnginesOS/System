module FrameworkModules
  def write_rake_list
    unless @blueprint_reader.rake_actions.nil? || @blueprint_reader.rake_actions.empty?
      write_comment('#Rake Actions')
      rakes = ''
      @blueprint_reader.rake_actions.each do |rake_action|
        rake_cmd = rake_action[:action]
        next if @builder.first_build == false && ! rake_action[:always_run]
        write_build_script('run_rake_task.sh ' + rake_cmd ) unless rake_cmd.nil?
      end
    end
  end

  def write_pear_modules
    unless @blueprint_reader.pear_modules.nil?|| @blueprint_reader.pear_modules.empty?
      write_comment('#Pear modules ')
      log_build_output('Dockerfile:Pear modules ')
      unless @blueprint_reader.pear_modules.nil?
        if @blueprint_reader.pear_modules.count > 0
          @blueprint_reader.pear_modules.each do |pear_mod|
            pear_mods += pear_mod + ' ' unless pear_mod.nil
          end
          write_build_script('install_pear_mods.sh  ' + pear_mods)
        end
      end
    end
  end

  def write_pecl_modules
    unless @blueprint_reader.pecl_modules.nil? || @blueprint_reader.pecl_modules.empty?
      write_comment('#Pecl modules ')
      log_build_output('Dockerfile:Pecl modules ')
      if @blueprint_reader.pecl_modules.count > 0
        pecl_mods = ''
        @blueprint_reader.pecl_modules.each do |pecl_mod|
          pecl_mods += pecl_mod + ' ' unless pecl_mod.nil?
        end
        write_build_script('install_pecl_mods.sh  ' + pecl_mods)
      end
    end
  end

  def write_apache_modules
    unless @blueprint_reader.apache_modules.nil? || @blueprint_reader.apache_modules.empty?
      write_comment('#Apache Modules')
      ap_modules_str = ''
      @blueprint_reader.apache_modules.each do |ap_module|
        ap_modules_str += ap_module + ' ' unless ap_module.nil?
      end
      write_run_line('a2enmod ' + ap_modules_str)
    end
  end

  def write_npm_modules
    unless @blueprint_reader.npm_modules.nil? || @blueprint_reader.npm_modules.empty?
      write_comment('#NPM Modules')
      npm_modules_str = ''
      @blueprint_reader.npm_modules.each do |npm_module|
        npm_modules_str += npm_module + ' ' unless npm_module.nil?
      end
      write_build_script('install_npm_modules.sh ' + npm_modules_str)
    end
  end

  def write_lua_modules
    unless @blueprint_reader.lua_modules.nil? || @blueprint_reader.lua_modules.empty?
      write_comment('#Lua Modules')
      lua_modules_str = ''
      @blueprint_reader.lua_modules.each do |lua_module|
        lua_modules_str += lua_module + ' ' unless lua_module.nil?
      end
      write_build_script('install_lua_modules.sh ' + lua_modules_str)
    end
  end

  def write_php_modules
    unless @blueprint_reader.php_modules.nil? || @blueprint_reader.php_modules.empty?
      write_comment('#PHP Modules')
      php_modules_str = ''
      @blueprint_reader.php_modules.each do |php_module|
        php_modules_str += php_module + ' ' unless php_module.nil?
      end
      write_build_script('install_php_modules.sh ' + php_modules_str)
    end
  end
end