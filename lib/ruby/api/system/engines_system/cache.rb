module Cache
  def engine_from_cache(ident)

    return  nil unless @engines_conf_cache.key?(ident.to_sym)   
    return  nil unless @engines_conf_cache[ident.to_sym].is_a?(Hash)
    return @engines_conf_cache[ident.to_sym][:engine] if @engines_conf_cache[ident.to_sym][:ts]  ==  get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
    @engines_conf_cache[ident.to_sym][:engine] = nil
       p :Stale_info 
       p :saved_ts
       p @engines_conf_cache[ident.to_sym][:ts]
         p :read_ts
         p get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
       p @engines_conf_cache[ident.to_sym][:engine]
       
return  nil
  end

  def rm_engine_from_cache(engine_name)
    @engines_conf_cache.delete(engine_name.to_sym)
  end

  def cache_engine( engine, ts)
    unless engine.ctype == 'service' 
      ident = engine.container_name
    else
      ident ='services/' + engine.container_name
    end 
  @engines_conf_cache[ident.to_sym] = {}
    @engines_conf_cache[ident.to_sym][:engine] = engine
    @engines_conf_cache[ident.to_sym][:ts] =  ts
    #Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
  end

  def get_engine_ts(engine)
   # p :get_engine_ts
    #p engine
    return log_error_mesg('Get ts passed nil Engine ', engine) if engine.nil?
    
    yam_file_name = SystemConfig.RunDir + '/' + engine.ctype + 's/' + engine.engine_name + '/running.yaml'
    return -1 unless File.exist?(yam_file_name)
    File.mtime(yam_file_name)
  end
  
  def container_from_cache(container_name)
    p :container_from_cache
    p container_name.to_s
    return nil if container_name.nil?
#    c = engine_from_cache('/services/' + container_name)
#    return c unless c.nil?
    return engine_from_cache(container_name)
  end
  
  def cache_update_ts(container, ts) 
    if container.ctype == 'service'
     ident = 'services/' + container.container_name
    else
      ident = container.container_name
    end
    id = ident.to_sym
    return false unless  @engines_conf_cache.key?(id) && ! @engines_conf_cache[id].nil?
    @engines_conf_cache[id][:ts] = ts
     return true
  end
  
end