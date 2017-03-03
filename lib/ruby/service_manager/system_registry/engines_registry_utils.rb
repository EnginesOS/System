module EnginesRegistryUtils
  
  def pe_sh_path(ahash)
    STDERR.puts('pe_sh_path:' + ahash.to_s)
    return ahash[:parent_engine] + '/'+  ahash[:service_handle]
  end
end

def st_path(ahash)
  STDERR.puts('st_path:' + ahash.to_s)
 return  ahash[:publisher_namespace] + '/'+  ahash[:type_path]
end

def address_params(hash,param_symbols)
  r = ''
  param_symbols.each do | sym |
    log_error_mesg('Hash Missing key!:'  + sym.to_s)
    r += '/' + hash[sym].to_s
  end
  r  
end

def pe_sh_st_path(ahash)
  pe_sh_path(ahash) + '/' + st_path(ahash)
end