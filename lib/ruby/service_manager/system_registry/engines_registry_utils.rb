
module EnginesRegistryUtils
#  
#  def pe_sh_path(ahash)
  # :parent_engine,:service_handle
#     ahash[:parent_engine] + '/'+  ahash[:service_handle]
#  end
#

#def st_path(ahash)
  #  :publisher_namespace,:type_path
#  ahash[:publisher_namespace] + '/'+  ahash[:type_path]
#end
  #def pe_sh_st_path(ahash)
  # :parent_engine,:service_handle,:publisher_namespace,:type_path
  #  pe_sh_path(ahash) + '/' + st_path(ahash)
  #end

def address_params(hash,param_symbols)
  r = ''
  param_symbols.each do | sym |
    return r unless hash.key?(sym)
    r += '/' + hash[sym].to_s  
    SystemDebug.debug(SystemDebug.services,r.to_s)
  end
SystemDebug.debug(SystemDebug.services,r.to_s)
  r  
rescue StandardError => e
  log_exception(e, hash)
end


end