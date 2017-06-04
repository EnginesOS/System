module EnginesRegistryUtils
  def address_params(hash, param_symbols)
    r = ''
    param_symbols.each do | sym |
      return r unless hash.key?(sym)
      r += '/' + hash[sym].to_s
    end
    SystemDebug.debug(SystemDebug.services, r.to_s)
    r
  end
end