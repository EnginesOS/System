module Containers
  # @param container_log file
  # @param retentioncount
  def rotate_container_log(container_id, retention = 10)
    run_server_script('rotate_container_log', "{#{container_id} #{retention}")
  end

  def save_container(container)
    serialized_object = YAML.dump(container)
    statefile = state_file(container, true)
    statedir = container_state_dir(container)
    log_error_mesg('container locked', container.container_name) unless lock_container_conf_file(statefile)
    backup_state_file(statefile)
    f = File.new("#{statefile}_tmp", File::CREAT | File::TRUNC | File::RDWR, 0600) # was statefile + '_tmp
    begin
      f.puts(serialized_object)
      f.flush()
      #Do it this way so a failure to write doesn't trash a working file
      if File.exist?("#{statefile}_tmp")
        #FixMe check valid yaml       
       FileUtils.mv("#{statefile}_tmp", statefile)
      else
        roll_back(statefile)
      end
    rescue StandardError => e
      STDERR.puts('Exception in writing Rolling back ' + e.to_s)
      roll_back(statefile)
    ensure
      f.close unless f.nil?
    end
    begin
      ts =  File.mtime(statefile)
    rescue StandardError => e
      ts = Time.now
    end
    unlock_container_conf_file(statedir)
    cache.add(container, ts) unless cache.update(container, ts)
    #STDERR.puts('saved ' + container.container_name + ':' + caller[1].to_s + ':' + caller[2].to_s)
    true
  rescue StandardError => e
    container.last_error = last_error unless container.nil?
    SystemUtils.log_exception(e)
  ensure
    unlock_container_conf_file(statedir)
  end

  def is_startup_complete?(container)
    File.exist?("#{container_state_dir(container)}/run/flags/startup_complete")
  end

  private

  def cache
    Container::Cache.instance
  end

  def backup_state_file(statefile)
    if File.exist?(statefile)
      statefile_bak = "#{statefile}.bak"

      begin
        if File.exist?(statefile_bak)
          #double handle in case fs full
          #if fs full mv fails and delete doesn't happen
          FileUtils.mv(statefile_bak, "#{statefile_bak}.bak")
          #Fixme check statefile is valid before over writing a good backup
          File.rename(statefile, statefile_bak)
          File.delete("#{statefile_bak}.bak")
        else
          File.rename(statefile, statefile_bak)
        end
      rescue StandardError => e
      end
    end
  end

  def state_file(container, create = true)
    state_dir = container_state_dir(container)
    FileUtils.mkdir_p(state_dir) if Dir.exist?(state_dir) == false && create == true
    "#{state_dir}/running.yaml"
  end

  def roll_back(statefile)
    FileUtils.mv("#{statefile}.bak", statefile)
  end

end
