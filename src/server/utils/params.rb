module Params
  def self.assemble_params(params, address_params, required_params, accept_params=nil )

    a_params = self.address_params(params, address_params)

    unless required_params.empty?
      return EngineError.new('Missing Address Parameters ' + address_params.to_s + ' but only have:' + params.to_s) if a_params == false
      r_params = self.required_params(params,required_params)
      return EngineError.new('Missing Parameters ' + required_params.to_s + ' but only have:' + params.to_s) if r_params == false
      a_params.merge!(r_params)
    end
    
    return a_params if accept_params.nils?
    
    unless accept_params.empty?
      o_params = self.optional_params(params,accept_params)
      a_params.merge!(o_params)
    end    
    a_params
  end

  def self.required_params(params, keys)
    mparams = params['api_vars']
      p :pre_SYM
     p  mparams
    m_params = Utils.symbolize_keys(mparams)
     p :POST_SYM
      p  m_params
    return false if m_params.nil?
    self.match_params(m_params, keys, true)
    #   Utils.symbolize_keys(matched)
  end

  def self.optional_params(params, keys)
    mparams = params['api_vars']
    m_params = Utils.symbolize_keys(mparams)

    return {} if m_params.nil?
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
        cparams[key.to_sym] = params[key] unless params[key].nil?
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