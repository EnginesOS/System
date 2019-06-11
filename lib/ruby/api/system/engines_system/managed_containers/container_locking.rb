module ContainerLocking

  @@lock_timeout = 3
  def unlock_container_conf_file(lock_key)
    @container_conf_locks.delete(lock_key) if @container_conf_locks.key?(lock_key)
  rescue StandardError
    false
  end

  def lock_container_conf_file(lock_key)
    #lock_key
    if is_container_conf_file_locked?(lock_key).is_a?(TrueClass)
      wait_on_lock(lock_key)
      @container_conf_locks[lock_key] = Thread.current
      true
    end
  rescue StandardError => e
    log_error_mesg('locking exception', e)
    true
  end

  private

  def is_container_conf_file_locked?(lock_key)
    if @container_conf_locks.key?(lock_key)
      if @container_conf_locks[lock_key].is_a?(Thread)
        if @container_conf_locks[lock_key].active?
          true
        else
          @container_conf_locks.delete(lock_key)
          false
        end
      else
        @container_conf_locks.delete(lock_key)
        false
      end
    else
      false
    end
  end

  def wait_on_lock(lock_key)
    thr = @container_conf_locks[lock_key]
    if thr.alive?
      STDERR.puts('waiting_to_clr_container_conf_file_locked ' +  lock_key.to_s + "\n by:" + thr.to_s)
      begin
        Timeout.timeout(@@lock_timeout) do
          begin
            thr.join
            STDERR.puts("lock holder thread returned " + lock_key.to_s)
          rescue
            STDERR.puts("lock holder thread join excepted " + lock_key.to_s)
          ensure
            unlock_container_conf_file(lock_key)
          end
        end
      rescue Timeout::Error
        unlock_container_conf_file(lock_key)
        STDERR.puts("Timeout Forced cleared lock in "+ lock_key.to_s)
        false
      end
    else
      unlock_container_conf_file(lock_key)
    end
  end
  
end
