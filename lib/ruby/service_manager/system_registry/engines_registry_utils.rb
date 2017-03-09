module EnginesRegistryUtils
  
  def pe_sh_path(ahash)
 #   STDERR.puts('pe_sh_path:' + ahash.to_s)
    return ahash[:parent_engine] + '/'+  ahash[:service_handle]
  end
end

def st_path(ahash)
 # STDERR.puts('st_path:' + ahash.to_s)
 return  ahash[:publisher_namespace] + '/'+  ahash[:type_path]
end

def address_params(hash,param_symbols)
  r = ''
  param_symbols.each do | sym |
 #   STDERR.puts('Hash Missing key!:'  + sym.to_s + ' in ' + hash.to_s) unless hash.key?(sym)
    return r unless hash.key?(sym)
    r += '/' + hash[sym].to_s  
    SystemDebug.debug(SystemDebug.services,r.to_s)
  end
SystemDebug.debug(SystemDebug.services,r.to_s)
return  r  
rescue StandardError => e
  log_exception(e, hash)
end

def pe_sh_st_path(ahash)
  pe_sh_path(ahash) + '/' + st_path(ahash)
end