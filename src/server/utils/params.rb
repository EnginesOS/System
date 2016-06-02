module Params
  def self.assemble_params(params, address_params, required_params, accept_params=nil )

    a_params = self.address_params(params, address_params)       
      
    r_params = self.required_params(params,required_params)
    a_params.merge!(r_params)
    
    o_params = self.optional_params(params,required_params)
    a_params.merge!(o_params)

   # ad_params.merge!(a_params)
    #    address_params = [:engine_name]
    #    accept_params = [:all]
    #    cparams = assemble_params(params, address_params, accept_params )
    #    cparams = address_params(params,  :engine_name) # , :variables)
    #    vars = params[:api_vars]
    #    Utils.symbolize_keys(vars)
    #    cparams.merge!(vars)
#    p ':assembled r_params + o_params + a_params'
#    p r_params
#    p o_params
#    p a_params
    a_params
  end

  def self.required_params(params, keys)
    mparams = params['api_vars']
    p :pre_SYM
    p  m_params 
    m_params = Utils.symbolize_keys(mparams)
    p :POST_SYM
    p  m_params 
    return nil if m_params.nil?
    self.match_params(m_params, keys, true)
    #   Utils.symbolize_keys(matched)
  end

  def self.optional_params(params, keys)
     mparams = params['api_vars']
     m_params = Utils.symbolize_keys(mparams)
     p :POST_SYM
     p
     return nil if m_params.nil?
    self.match_params(m_params, keys )
     #   Utils.symbolize_keys(matched)
   end
  
  def self.address_params(params, keys)
     self.match_params(params, keys)    
  end

  def self.match_params(params, keys, required = false)
    return  params if keys == :all
    
    cparams =  {}
    return cparams if keys.nil?
     
    if keys.is_a?(Array)
      for key in keys
        # return missing_param key unless param.key?(key)

        return false  unless self.check_required(params, key,required )     
        cparams[key.to_sym] = params[key]        
      end
    else
      return false  unless  self.check_required(params, keys,required)
      cparams[keys.to_sym] = params[keys]
    end
    cparams
rescue StandardError => e
  p e
  p e.backtrace
  end

 def self.check_required(params, key, is_required)
   return true unless is_required
   return true if params.key?(key)
   p :missing_key
   p key
   return false
end

#  def accept_params(params , *keys)
#    cparams = {}
#    for key in keys
#      cparams[key] = params[key]
#    end
#    cparams
#    #  cparams = {}
#    #  cparams[:configurator_name] = params[:configurator_name]
#  end

end