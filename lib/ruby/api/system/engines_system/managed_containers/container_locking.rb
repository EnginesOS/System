class SystemApi
  @@lock_timeout = 5
  def unlock_container_conf_file(lock_key)
    STDERR.puts("UNLOCKING " + lock_key.to_s)
    @container_conf_locks.delete(lock_key) if @container_conf_locks.key?(lock_key)
  rescue StandardError
    false
  end

  def lock_container_conf_file(lock_key)
    STDERR.puts("LOCKING " + lock_key.to_s)
    if is_container_conf_file_locked?(lock_key).is_a?(TrueClass)
      wait_on_lock(lock_key)
      @container_conf_locks[lock_key] = Thread.current
      true
    end
  rescue StandardError => e
    log_error_mesg('LOCKING locking exception', e)
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
      STDERR.puts('LOCKING waiting_to_clr_container_conf_file_locked ' +  lock_key.to_s + "\n by:" + thr.to_s)
      begin
        Timeout.timeout(@@lock_timeout) do
          begin
            thr.join
            STDERR.puts("LOCKING lock holder thread returned " + lock_key.to_s)
          rescue
            STDERR.puts("LOCKING lock holder thread join excepted " + lock_key.to_s)
          ensure
            STDERR.puts("LOCKING Ensure Forced cleared lock in "+ lock_key.to_s)
            unlock_container_conf_file(lock_key)
          end
        end
      rescue Timeout::Error
        unlock_container_conf_file(lock_key)
        STDERR.puts("LOCKING Timeout Forced cleared lock in "+ lock_key.to_s)
        false
      end
    else
      unlock_container_conf_file(lock_key)
    end
  end
  
end
