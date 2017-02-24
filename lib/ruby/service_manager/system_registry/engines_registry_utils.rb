module EnginesegistryUtils
  
  def pe_sh_path(ahash)
    return ahash[:parent_engine] + '/'+  ahash[:service_handle]
  end
end

def st_path(ahash)
 return  ahash[:publisher_namespace] + '/'+  ahash[:type_path]
end

def pe_sh_st_path(ahash)
  pe_sh_path(ahash) + '/' + st_path(ahash)
end