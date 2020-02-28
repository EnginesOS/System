class ContainerLocking
  require '/opt/engines/lib/ruby/api/system/errors_api'
  
  def instance
    @@instance ||= self.new
  end
 
  def lock_register
    @lock_register ||= {}
  end
  
  @@lock_timeout = 5

    def unlock(lock_key)
      lock_register.delete(lock_key) if lock_register.key?(lock_key)
    rescue StandardError
      false
    end

    def lock(lock_key)
      #lock_key
      STDERR.puts("LOCKING " + lock_key.to_s)
      if is_locked?(lock_key)
        wait_on_lock(lock_key)
      else 
        lock_register[lock_key] = Thread.current
        true      
      end    
    rescue StandardError => e
      errors_api.log_error_mesg('LOCKING locking exception', e)
      true
    end

    private

    def is_locked?(lock_key)
      if lock_register.key?(lock_key)
        if lock_register[lock_key].is_a?(Thread)
          if lock_register[lock_key].active?
            true
          else
        lock_register.delete(lock_key)
            false
          end
        else
      lock_register.delete(lock_key)
          false
        end
      else
        false
      end
    end

    def wait_on_lock(lock_key)
      thr = lock_register[lock_key]
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
              unlock(lock_key)
            end
          end
        rescue Timeout::Error
          unlock(lock_key)
          STDERR.puts("LOCKING Timeout Forced cleared lock in "+ lock_key.to_s)
          false
        end
      else
        unlock(lock_key)
      end
    end

    def errors_api
      @errors_api ||= ErrorsApi.new
    end
end