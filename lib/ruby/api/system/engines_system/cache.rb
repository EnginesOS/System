module Cache
  
  def engine_from_cache(ident)
      
      return  @engines_conf_cache[ident.to_sym] if @engines_conf_cache.key?(ident.to_sym)
      return nil
    end
    
    def delete_engine(engine_name)
      @engines_conf_cache.delete(engine_name.to_sym)
    end
    
    def cache_engine(ident, engine)
      @engines_conf_cache[ident.to_sym] = engine 
  Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
    end
  
end