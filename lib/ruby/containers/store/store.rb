require '/opt/engines/lib/ruby/api/system/container_state_files'
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
        d if File.exists?("#{store_directory}/#{d}/running.yaml")          
      end.compact
    end

    def save(c)
      c.clear_to_save
      serialized_object = YAML.dump(c)
      statefile = state_file(c, true)
      statedir = ContainerStateFiles.container_state_dir(c.store_address)
      log_error_mesg('container locked', c.container_name) unless lock(statefile)
      backup_state_file(statefile)
      f = File.new("#{statefile}_tmp", File::CREAT | File::TRUNC | File::RDWR, 0600) # was statefile + '_tmp
      begin
        f.puts(serialized_object)
        f.flush
        f.close
        #Do it this way so a failure to write doesn't trash a working file
        if File.exist?("#{statefile}_tmp")
          #FixMe check valid yaml
         FileUtils.mv("#{statefile}_tmp", statefile) 
        else
          #roll_back(statefile)
          STDERR.puts("#{statefile}_tmp Vanished\n" * 5)
          STDERR.puts("#{caller}")
        end
      rescue StandardError => e
        STDERR.puts("Exception in writing running #{e} \n #{e.backtrace}")
        roll_back(statefile)
      ensure
        f.close unless f.nil?
      end
      begin
        ts =  File.mtime(statefile)
      rescue StandardError => e
        ts = Time.now
      end
      unlock(statedir)
      cache.add(c, ts) unless cache.update(c, ts)
      #STDERR.puts('saved ' + container.container_name + ':' + caller[1].to_s + ':' + caller[2].to_s)
      true
    rescue StandardError => e
      #c.last_error = last_error unless c.nil?
      SystemUtils.log_exception(e)
    ensure
      unlock(statedir)
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

    def file(name)      
      File.new(file_name(name), 'r')
    end

    def file_exists?(name)
      File.exist?(file_name(name))
    end

    def file_name(name)
      "#{store_directory}/#{name}/running.yaml"
    end

    def store_directory
      "#{SystemConfig.RunDir}/#{container_type}s"
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
            FileUtils.mv(statefile_bak, "#{statefile_bak}.bak")
            #Fixme check statefile is valid before over writing a good backup
            File.rename(statefile, statefile_bak)
            File.delete("#{statefile_bak}.bak")
          else
            File.rename(statefile, statefile_bak) if File.exist?(statefile)
          end
        rescue StandardError => e
          STDERR.puts("Failed to backup_state_file #{e} \n #{e.backtrace}")
        end
      end
    end

    def state_file(container, create = true)
      state_dir = ContainerStateFiles.container_state_dir(container.store_address)
      FileUtils.mkdir_p(state_dir) if Dir.exist?(state_dir) == false && create == true
      "#{state_dir}/running.yaml"
    end

    def roll_back(statefile)
      STDERR.puts("Rollback #{statefile}\n #{caller}")
      # if exists to catch case of fsconfigurator
      FileUtils.mv("#{statefile}.bak", statefile) if File.exist?("#{statefile}.bak")
    end
  end
end
