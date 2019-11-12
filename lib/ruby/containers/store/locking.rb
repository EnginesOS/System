require '/opt/engines/lib/ruby/api/system/errors_api'

module Container
  class Store

    @@lock_timeout = 5
    def unlock(lock_key)
      container_conf_locks.delete(lock_key) if container_conf_locks.key?(lock_key)
    rescue StandardError
      false
    end

    def lock(lock_key)
      wait_on_lock(lock_key) if is_locked?(lock_key)
      container_conf_locks[lock_key] = Thread.current
      true
    rescue StandardError => e
      errors_api.log_error_mesg('LOCKING exception', e)
      false
    end

    def is_locked?(lock_key)
      if container_conf_locks.key?(lock_key)
        STDERR.puts "Found LOCK #{container_conf_locks[lock_key].class.name} in #{container_conf_locks}"
        if container_conf_locks[lock_key].is_a?(Thread)
          if container_conf_locks[lock_key].alive?
            STDERR.puts "ACTIVE" * 12
            true
          else
            container_conf_locks.delete(lock_key)
            STDERR.puts "NOACTIVE" * 12
            STDERR.puts "LOCK #{lock_key}"
            false
          end
        else
          container_conf_locks.delete(lock_key)
          STDERR.puts "NOT THREAD" * 12
          STDERR.puts "LOCK #{lock_key}"
          false
        end
      else
        false
      end
    rescue StandardError => e
      SystemUtils.log_exception(e)
      false
    end

    def wait_on_lock(lock_key)
      STDERR.puts("LOCKING waiting_to_clr_container_conf_file_locked ")
      STDERR.puts("#{lock_key}\n by: #{container_conf_locks[lock_key]}")
      thr = container_conf_locks[lock_key]
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
        rescue Timeout::Error =>e
          unlock(lock_key)
          STDERR.puts("LOCKING Timeout Forced cleared lock in "+ lock_key.to_s)
          false
        end
      else
        unlock(lock_key)
      end
    rescue # Fix ME just catch thr nill
      unlock(lock_key)
    end

    def errors_api
      @errors_api ||= ErrorsApi.new
    end
  end
end
