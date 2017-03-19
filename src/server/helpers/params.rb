require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'

def error_hash(mesg, *parms)
  {
    error_type: error,
    params: params,
    source: caller[1..4],
    system:  'api',
    error_mesg: msg
  }
end

def assemble_params(ps, address_params, required_params=nil, accept_params=nil )
  
  raise EnginesException.new(error_hash('No params Supplied')) if ps.nil?
  #  STDERR.puts('posted ' + params.to_s)
  #ps = Utils.symbolize_keys(ps)
  ps = deal_with_json(ps)
  a_params = match_address_params(ps, address_params)
  raise EnginesException.new(error_hash('Missing Address Parameters ' + address_params.to_s + ' but only have:' + ps.to_s)) if a_params == false

  unless  required_params.nil? || required_params.empty?
    if required_params == :all
      a_params.merge!(ps[:api_vars]) if ps.key?(:api_vars)
      return a_params
    end
    r_params = required_params(ps,required_params)
    raise EnginesException.new(error_hash('Missing Parameters ' + required_params.to_s + ' but only have:' + ps.to_s)) if r_params == false
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
  false
end

def service_hash_from_params(params, search)
  #   splats = params['splat']
  #    hash = {}
  #  hash[:publisher_namespace] = params['publisher_namespace']
  unless search
    params[:type_path] = File.dirname(params['splat'][0])
    params[:service_handle] = File.basename(params['splat'][0])
  else
    params[:type_path] =  params['splat'][0]
  end
  params
end

def engine_service_hash_from_params(params, search = false)
  hash = service_hash_from_params(params, search)
  hash[:parent_engine] = params['engine_name']
  hash[:container_type] = 'container'
  hash
end

def service_service_hash_from_params(params, search = false)
  hash = service_hash_from_params(params, search)
  hash[:parent_engine] = params['service_name']
  hash[:container_type] = 'service'
  hash
end

