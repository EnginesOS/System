module Cache
  def engine_from_cache(ident)
    r =- nil
    if @engines_conf_cache.key?(ident.to_sym) && @engines_conf_cache[ident.to_sym].is_a?(Hash)
      unless @engines_conf_cache[ident.to_sym][:engine].nil?
        ts = get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
        if ts == -1
          rm_engine_from_cache(ident)
          SystemDebug.debug(SystemDebug.cache, :Expire_in_CACHE, ident)
        else
          SystemDebug.debug(SystemDebug.cache, :FROM_CACHE, ident)
          if @engines_conf_cache[ident.to_sym][:ts] == ts
           r=  @engines_conf_cache[ident.to_sym][:engine]
          else
            SystemDebug.debug(SystemDebug.cache, :Stale_in_Cache )
            r= @engines_conf_cache[ident.to_sym][:engine] = nil
          end
        end
      end
    end
    r
  end

  def rm_engine_from_cache(engine_name)
    SystemDebug.debug(SystemDebug.cache, :RM_FROM_CACHE, engine_name)
    @engines_conf_cache.delete(engine_name.to_sym)
  end

  def cache_engine( engine, ts)
    ident =  get_ident(engine)
    SystemDebug.debug(SystemDebug.cache, :ADD_TO_CACHE, ident, engine.container_name)
    @engines_conf_cache[ident.to_sym] = {
      engine: engine,
      ts: ts
    }
    @engines_conf_cache[engine.container_id] = ident
  end

  def get_ident(container)
    if container.ctype == 'service'
      ident = 'services/' + container.container_name
    else
      ident = container.container_name
    end
  end

  def container_name_from_id(id)
    ident = @engines_conf_cache[id]
    ident.gsub!(/services\//, '') unless ident.nil?
    ident
  end

  def get_engine_ts(engine)
    raise EnginesException.new(error_hash('Get ts passed nil Engine ', engine)) if engine.nil?
    yam_file_name = SystemConfig.RunDir + '/' + engine.ctype + 's/' + engine.engine_name + '/running.yaml'
    if File.exist?(yam_file_name)
      File.mtime(yam_file_name)
    else
      -1
    end
  end

  def container_from_cache(container_ident)
    unless container_ident.nil?
      engine_from_cache(container_ident)
    end
  end

  def cache_update_ts(container, ts)
    ident =  get_ident(container)
    name_key = ident.to_sym
    if @engines_conf_cache.key?(name_key) && ! @engines_conf_cache[name_key].nil?
      @engines_conf_cache[name_key][:ts] = ts
      true
    else
      false
    end
  end

end