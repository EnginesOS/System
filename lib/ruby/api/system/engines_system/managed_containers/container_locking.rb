module ContainerLocking

  @@lock_timeout  = 3

  def unlock_container_conf_file(state_dir)
    @container_conf_locks.delete(state_dir) if @container_conf_locks.key?(state_dir)
  rescue StandardError
    false
  end

  def is_container_conf_file_locked?(state_dir)
    r = @container_conf_locks.key?(state_dir)  
    STDERR.puts('is Container ' + state_dir.to_s + ' locked = ' + r.to_s)
    r
  end

  def lock_container_conf_file(state_dir)
    if @container_conf_locks.key?(state_dir)
      wait_on_lock(state_dir)     
      @container_conf_locks[state_dir] = Thread.current
      true
    end
  rescue StandardError => e
    log_error_mesg('locking exception', e)
    true
  end
  
  private 
  def wait_on_lock(state_dir)
    thr = @container_conf_locks[state_dir]
         if thr.alive?          
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
             end
           rescue Timeout::Error
             unlock_container_conf_file(state_dir)
             STDERR.puts("Timeout Forced cleared lock in "+ state_dir.to_s)
             false
           end
         end
end
end