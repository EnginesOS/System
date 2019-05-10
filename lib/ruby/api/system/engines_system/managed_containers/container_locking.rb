module ContainerLocking

  @@lock_timeout  = 2
  def lock_has_expired(lock_fn)
    if File.mtime(lock_fn) <  Time.now + @@lock_timeout
      true
    else
      false
    end
  rescue StandardError
    true
  end

  def unlock_container_conf_file(state_dir)
    File.delete(state_dir + '/lock') if  File.exists?(state_dir + '/lock')
  rescue StandardError
    false
  end

  def is_container_conf_file_locked?(state_dir)
    lock_fn = state_dir + '/lock'
    if File.exists?(lock_fn)
      loop = 0
      while File.exists?(lock_fn)
        sleep(0.2)
        STDERR.puts('_container_conf_file_locked ')
        loop != 1
        break if loop > 5
      end
      File.exists?(lock_fn)
    else
      false
    end
  end

  def lock_container_conf_file(state_dir)
    lock_fn = state_dir + '/lock'
    if  File.exists?(lock_fn) && lock_has_expired(lock_fn) == false
      loop = 0

      while  File.exists?(lock_fn)
        sleep(0.2)
        loop += 1
        STDERR.puts('waiting_to_clr_container_conf_file_locked ')
        if loop > 10
          pid = File.read(lock_fn)
          log_error_mesg("cleared lock in ",state_dir,' pid ',pid)
          File.delete(lock_fn)
          break
        end
      end
    else
      lock = File.new(lock_fn, File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        lock.puts(Process.pid.to_s)
      ensure
        lock.close()
      end
    end
    true
  rescue StandardError => e
    log_error_mesg('locking exception', lock_fn,e)
    true
  end
end