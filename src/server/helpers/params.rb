def assemble_params(ps, address_params, required_params=nil, accept_params=nil )
  # STDERR.puts( 'assemble_params Address params ' + ps.to_s + ' address keys required ' + address_params.to_s)
    return nil if ps.nil?
   ps = Utils.symbolize_keys(ps)
    a_params = match_address_params(ps, address_params)
    return EnginesError.new('Missing Address Parameters ' + address_params.to_s + ' but only have:' + ps.to_s, :error,'api') if a_params == false
  
    unless  required_params.nil? || required_params.empty?
      if required_params == :all
        a_params.merge!(ps[:api_vars]) if ps.key?(:api_vars)
        return a_params
      end
      r_params = self.required_params(ps,required_params)
      return EnginesError.new('Missing Parameters ' + required_params.to_s + ' but only have:' + ps.to_s, :error,'api') if r_params == false
      a_params.merge!(r_params) unless r_params.nil?
    end
    return a_params if accept_params.nil?
    unless accept_params.empty?
      o_params = optional_params(ps ,accept_params)
      a_params.merge!(o_params) unless o_params.nil?
    end
    a_params
  end

  def required_params(params, keys)
    mparams = params[:api_vars]
    return false if mparams.nil?
    match_params(mparams, keys, true)
  end

  def optional_params(params, keys)
    mparams = params[:api_vars]
    mparams = params if mparams.nil?
    match_params(mparams, keys )
  end

  def match_address_params(params, keys)
    # STDERR.puts( 'Address params ' + params.to_s + ' keys required ' + keys.to_s)
    match_params(params, keys, true)
  end

  def match_params(params, keys, is_required = false)
    return  params if keys == :all
    return nil if keys.nil?
    cparams =  {}
    if keys.is_a?(Array)
      for key in keys
        # return missing_param key unless param.key?(key)
        return false  unless  check_required(params, key, is_required)
        cparams[key.to_sym] = params[key] unless params[key].nil?
      end
    else
      return false unless check_required(params, keys, is_required)
      cparams[keys.to_sym] = params[keys]
    end
    cparams
  rescue StandardError => e
    p e
    p e.backtrace
  end

  def check_required(params, key, is_required)
    return true unless is_required
    return true if params.key?(key)
    p :missing_key
    p key
    return false
  end
