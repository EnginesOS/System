module Cache
  def engine_from_cache(ident)

    return  nil unless @engines_conf_cache.key?(ident.to_sym)
    return @engines_conf_cache[ident.to_sym][:engine] if @engines_conf_cache[ident.to_sym][:ts]  =  get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
    
  end

  def delete_engine(engine_name)
    @engines_conf_cache.delete(engine_name.to_sym)
  end

  def cache_engine(ident, engine)
  @engines_conf_cache[ident.to_sym] = {}
    @engines_conf_cache[ident.to_sym][:engine] = engine
    @engines_conf_cache[ident.to_sym][:ts] =  get_engine_ts(engine)
    Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
  end

  def get_engine_ts(engine)
    0
  end
end