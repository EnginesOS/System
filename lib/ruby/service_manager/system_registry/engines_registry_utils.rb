module EnginesRegistryUtils
  def address_params(hash, param_symbols)
    r = ''
  #  STDERR.puts('address_params req ' + param_symbols.to_s)
    param_symbols.each do | sym |
   #   STDERR.puts('address_params sym ' + sym.to_s)
      return r unless hash.key?(sym)
      r += '/' + hash[sym].to_s
     # SystemDebug.debug(SystemDebug.services,r.to_s)
    #  STDERR.puts('address_params val ' + r.to_s)
    end
    SystemDebug.debug(SystemDebug.services,r.to_s)
  # STDERR.puts('address_params val ' + r.to_s)
    r

  end
end