module Cache
  def engine_from_cache(ident)

    return  nil unless @engines_conf_cache.key?(ident.to_sym)   
    return  nil unless @engines_conf_cache[ident.to_sym].is_a?(Hash)
    return @engines_conf_cache[ident.to_sym][:engine] if @engines_conf_cache[ident.to_sym][:ts]  ==  get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
    @engines_conf_cache[ident.to_sym][:engine] = nil
return  nil
  end

  def rm_engine_from_cache(engine_name)
    @engines_conf_cache.delete(engine_name.to_sym)
  end

  def cache_engine(ident, engine, ts)
  @engines_conf_cache[ident.to_sym] = {}
    @engines_conf_cache[ident.to_sym][:engine] = engine
    @engines_conf_cache[ident.to_sym][:ts] =  ts
    #Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
  end

  def get_engine_ts(engine)
   # p :get_engine_ts
    #p engine
    return log_error_mesg(' Engine name', engine) if engine.nil?
    
    yam_file_name = SystemConfig.RunDir + '/' + engine.ctype + 's/' + engine.engine_name + '/running.yaml'
    return -1 unless File.exist?(yam_file_name)
    File.mtime(yam_file_name)
  end
end