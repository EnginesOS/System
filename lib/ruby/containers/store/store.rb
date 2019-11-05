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
  end
end
