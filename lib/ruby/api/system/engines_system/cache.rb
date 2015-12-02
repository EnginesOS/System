module Cache
  def engine_from_cache(ident)

    return  nil unless @engines_conf_cache.key?(ident.to_sym)   
    return  nil unless @engines_conf_cache[ident.to_sym].is_a?(Hash)
   
    return @engines_conf_cache[ident.to_sym][:engine] if @engines_conf_cache[ident.to_sym][:ts]  ==  get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
   
       p :Stale_info 
#       p :saved_ts
#       p @engines_conf_cache[ident.to_sym][:ts]
#         p :read_ts
#         p get_engine_ts(@engines_conf_cache[ident.to_sym][:engine])
#      # p @engines_conf_cache[ident.to_sym][:engine]

         #  refresh cache  Done by the caller as load add s to cache       
@engines_conf_cache[ident.to_sym][:engine] = nil
       
return  nil
  end

  def rm_engine_from_cache(engine_name)
    p :RM_FROM_CACHE
    @engines_conf_cache.delete(engine_name.to_sym)
   
  end

  def cache_engine( engine, ts)

      ident =  get_ident(engine)

  @engines_conf_cache[ident.to_sym] = {}
    @engines_conf_cache[ident.to_sym][:engine] = engine
    @engines_conf_cache[ident.to_sym][:ts] =  ts
    @engines_conf_cache[engine.container_id] = ident
     
    #Thread.new { sleep 5; @engines_conf_cache[ident.to_sym] = nil }
  end

  def get_ident(container)
    if container.ctype == 'service'
             ident = 'services/' + container.container_name
             else
               ident = container.container_name
         end
  end
  
  def container_name_from_id(id)
    @engines_conf_cache[id]
  end
  
  def get_engine_ts(engine)
    p :get_engine_ts
   
    if engine.nil?
      
      @engines_conf_cache.each do |entry|
        p entry[:engine].container_name
      end
    return log_error_mesg('Get ts passed nil Engine ', engine)
    end
    yam_file_name = SystemConfig.RunDir + '/' + engine.ctype + 's/' + engine.engine_name + '/running.yaml'
    return -1 unless File.exist?(yam_file_name)
    File.mtime(yam_file_name)
  end
  
  def container_from_cache(container_ident)
    p :container_from_cache
    p container_ident.to_s
    return nil if container_ident.nil?
#    c = engine_from_cache('/services/' + container_name)
#    return c unless c.nil?
    return engine_from_cache(container_ident)
  end
  
  def cache_update_ts(container, ts) 
    ident =  get_ident(container)
    name_key = ident.to_sym
    return false unless  @engines_conf_cache.key?(name_key) && ! @engines_conf_cache[name_key].nil?
    @engines_conf_cache[name_key][:ts] = ts
     return true
  end
  
end