require '/opt/engines/lib/ruby/api/system/container_state_files'
require_relative 'files'
require_relative 'cache'
require_relative 'store_locking'

module Container
  class Store
    class << self
      def instance
        @@instance ||= self.new
      end
    end

    def model(name)
      cache.container(name) || load(name)
    end

    def all
      all_names.map do |n|
        #begin
        model(n)
        #rescue EnginesException
        #end
      end.compact
    end

    def all_names
      Dir.entries(store_directory).map do |d|
        d if file_exists?(d)
      end.compact
    end

    #looking waits on this thread to complete
    def save(c)
      t = Thread.new  { _save(c) }
      t.join
    end

    def _save(c)
      STDERR.puts "Save #{c.container_name} #{container_conf_locks}"
      c.clear_to_save
      statefile = state_file(c, true)
      statedir = c.store.container_state_dir(c.container_name)
      errors_api.log_error_mesg('container locked', c.container_name) unless lock(statefile)
      backup_state_file(statefile)
      serialized_object = YAML.dump(c)
      f = File.new("#{statefile}_tmp", File::CREAT | File::TRUNC | File::RDWR, 0600) # was statefile + '_tmp
      begin
        f.puts(serialized_object)
        f.flush()
        #Do it this way so a failure to write doesn't trash a working file
        if File.exist?("#{statefile}_tmp")
          #FixMe check valid yaml
          FileUtils.mv("#{statefile}_tmp", statefile)
        else
          STDERR.puts("#{statefile}_tmp is Missing")
          roll_back(statefile)
        end
      rescue StandardError => e
        STDERR.puts('Exception in writing Rolling back ' + e.to_s)
        roll_back(statefile)
      ensure
        f.close unless f.nil?
      end
        ts = File.mtime(statefile)
        cache.add(c, ts) unless cache.update(c, ts)
    rescue StandardError => e
      c.last_error = e.to_s unless c.nil?
      SystemUtils.log_exception(e)
    ensure
      unlock(statefile)
    end

    protected

    def cache
      Cache.instance
    end

    def load(name)
      begin
        n = file_name(name)
        lock(n)
        f = file(name)
        c = model_class.from_yaml(f.read)
        cache.add(c, File.mtime(n))
        c   #WTF why is cache.add not returning container?
      rescue Errno::ENOENT => e
        raise EnginesException.new(error_hash("No Container file:#{n}", name))
      ensure
        f.close unless f.nil?
        unlock(n)
      end
    end

    def model_class
      ManagedEngine
    end

    def container_type
      'app'
    end

    private

    def backup_state_file(statefile)
      if File.exist?(statefile)
        statefile_bak = "#{statefile}.bak"
        begin
          if File.exist?(statefile_bak)
            #double handle in case fs full
            #if fs full mv fails and delete doesn't happen
            begin
              File.delete("#{statefile_bak}.bak") if File.exist?("#{statefile_bak}.bak")
              FileUtils.mv(statefile_bak, "#{statefile_bak}.bak")
            rescue
            end
            #Fixme check statefile is valid before over writing a good backup
            File.rename(statefile, statefile_bak)
            File.delete("#{statefile_bak}.bak")
          else
            File.rename(statefile, statefile_bak)
          end
        rescue StandardError => e
          SystemUtils.log_exception(e)
        end
      end
    end

    def state_file(c, create = true)
      state_dir = c.store.container_state_dir(c.container_name)
      FileUtils.mkdir_p(state_dir) if Dir.exist?(state_dir) == false && create == true
      c.store.file_name(c.container_name)
    end

    def roll_back(statefile)
      FileUtils.mv("#{statefile}.bak", statefile)
    end

    def container_conf_locks
      @container_conf_locks ||= {}
    end
  end
end
