require_relative 'cache'

module Container
  class Store
    def model(name)
      cache.container(name) || load(name)
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
        c = ManagedEngine.from_yaml(f.read)
        cache.add(c, File.mtime(n))
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

    def file_name(name)
      "#{SystemConfig.RunDir}/#{container_type}s/#{name}/running.yaml"
    end

    def container_type
      'app'
    end
  end
end
