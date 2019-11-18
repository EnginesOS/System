module Container
  class Cache
    class << self
      def instance
        @@instance ||= self.new
      end
    end

    def container(ident)
      if ident
        r = nil
        if cache.key?(ident.to_sym) && cache[ident.to_sym].is_a?(Hash)
          unless cache[ident.to_sym][:engine].nil?
            ts = engine_ts(cache[ident.to_sym][:engine])
            if ts.nil?
              remove(ident)
            else
              if cache[ident.to_sym][:ts] == ts
                r = cache[ident.to_sym][:engine]
              else
                r = cache[ident.to_sym][:engine] = nil
              end
            end
          end
        end
        r
      end
    end

    def add(container, ts)
      i = ident(container)
      cache[i.to_sym] = { engine: container, ts: ts }
      cache[container.id] = i
      container
    end

    def update(container, ts)
      ident =  ident(container)
      name_key = ident.to_sym
      if cache.key?(name_key) && ! cache[name_key].nil?
        cache[name_key][:ts] = ts
        true
      else
        false
      end
    end

    def remove(name)
      cache.delete(name.to_sym)
    end

    private

    def ident(container)
      if container.ctype == 'service'
        ident = 'services/' + container.container_name
      else
        ident = container.container_name
      end
    end

    def engine_ts(engine)
      raise EnginesException.new(error_hash('Get ts passed nil Engine ', engine)) if engine.nil?
      #FIX ME use container_state sudke ewdssdf
      file_name = engine.store.file_name(engine.container_name)
      if File.exist?(file_name)
        begin
          File.mtime(file_name)
        rescue StandardError => e
          STDERR.puts(file_name + 'not found')
          nil
        end
      else
        nil
      end
    end

    def container_name_from_id(id)
      ident = cache[id]
      ident.gsub!(/services\//, '') unless ident.nil?
      ident
    end

    def cache
      @cache ||= {}
    end
  end
end
