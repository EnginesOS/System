module ContainerLocking

  @@lock_timeout  = 2
  #  def lock_has_expired(lock_fn)
  #    if File.mtime(lock_fn) <  Time.now + @@lock_timeout
  #      true
  #    else
  #      false
  #    end
  #  rescue StandardError
  #    true
  #  end
  def unlock_container_conf_file(state_dir)
    STDERR.puts('Container ' + state_dir.to_s + 'unlocked' )
    @container_conf_locks.delete(state_dir) if @container_conf_locks.key?(state_dir)
    #  File.delete(state_dir + '/lock') if  File.exists?(state_dir + '/lock')
  rescue StandardError
    false
  end

  def is_container_conf_file_locked?(state_dir)
    r = @container_conf_locks.key?(state_dir)
    STDERR.puts('is Container ' + state_dir.to_s + ' locked =' + r.to_s)
    r
    #    lock_fn = state_dir + '/lock'
    #    if File.exists?(lock_fn)
    #      loop = 0
    #      while File.exists?(lock_fn)
    #        sleep(0.2)
    #        STDERR.puts('_container_conf_file_locked ')
    #        loop != 1
    #        break if loop > 5
    #      end
    #      File.exists?(lock_fn)
    #    else
    #      false
    #    end
  end

  def lock_container_conf_file(state_dir)
    if @container_conf_locks.key?(state_dir)
      thr = @container_conf_locks[state_dir]
      STDERR.puts('waiting_to_clr_container_conf_file_locked ' +  state_dir.to_s + "\n by:" + thr.to_s)
      begin
        Timeout.timeout(@@lock_timeout) do
          begin
            thr.join
            STDERR.puts("lock holder thread returned " + state_dir.to_s)
          rescue             
            STDERR.puts("lock holder thread join excepted " + state_dir.to_s)
          ensure
            unlock_container_conf_file(state_dir)          
          end
          true
        end
      rescue Timeout::Error
        unlock_container_conf_file(state_dir)
        STDERR.puts("Timeout Forced cleared lock in "+ state_dir.to_s)
        false
      end
    else
      @container_conf_locks[state_dir] = Thread.current
      true
    end
    #    lock_fn = state_dir + '/lock'
    #    if  File.exists?(lock_fn) && lock_has_expired(lock_fn) == false
    #      loop = 0
    #      #FIXME use ioctl
    #      while File.exists?(lock_fn)
    #        sleep(0.2)
    #        loop += 1
    #        STDERR.puts('waiting_to_clr_container_conf_file_locked ')
    #        if loop > 10
    #          pid = File.read(lock_fn)
    #          log_error_mesg("cleared lock in ",state_dir,' pid ',pid)
    #          File.delete(lock_fn)
    #          break
    #        end
    #      end
    #    else
    #      lock = File.new(lock_fn, File::CREAT | File::TRUNC | File::RDWR, 0644)
    #      begin
    #        lock.puts(Process.pid.to_s)
    #      ensure
    #        lock.close()
    #      end
    #    end
    #true
  rescue StandardError => e
    log_error_mesg('locking exception', e)
    true
  end
end