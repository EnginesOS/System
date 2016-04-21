begin
  require 'sinatra'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'

  require_relative 'utils.rb'

  set :sessions, true
  set :logging, true
  set :run, true

  @@core_api = EnginesCore.new

  require_relative 'api/routes.rb'

  get '/v0/*' do
    p :No_Such_GET
    p :params
    status(404)
  end

  def assemble_params(params, address_params, required_params, accept_params=nil )

    ad_params = address_params(params, address_params)
    
    r_params = required_params(params,required_params)
    
   # a_params = accepted_params(params,required_params)
    
    ad_params.merge!(r_params)
   # ad_params.merge!(a_params)
    #    address_params = [:engine_name]
    #    accept_params = [:all]
    #    cparams = assemble_params(params, address_params, accept_params )
    #    cparams = address_params(params,  :engine_name) # , :variables)
    #    vars = params[:api_vars]
    #    Utils.symbolize_keys(vars)
    #    cparams.merge!(vars)
  end

  def required_params(params, keys)
    mparams = params['api_vars']
    m_params = Utils.symbolize_keys(mparams)
    p :POST_SYM
    p
    return nil if m_params.nil?
    match_params(m_params, keys, true)
    #   Utils.symbolize_keys(matched)
  end

  def accepted_params(params, keys)
     mparams = params['api_vars']
     m_params = Utils.symbolize_keys(mparams)
     p :POST_SYM
     p
     return nil if m_params.nil?
     match_params(m_params, keys )
     #   Utils.symbolize_keys(matched)
   end
  
  def address_params(params, keys)
    match_params(params, keys)
  end

  def match_params(params, keys, required = false)
    return  params if keys == :all
    
    cparams =  {}
    return cparams if keys.nil?
     
    if keys.is_a?(Array)
      for key in keys
        # return missing_param key unless param.key?(key)
        if required
          return false unless cparams.key?(key)
        end
        cparams[key.to_sym] = params[key]        
      end
    else
      cparams[keys.to_sym] = params[keys]
    end
    cparams
rescue StandardError => e
  p e
  p e.backtrace
  end

  def accept_params(params , *keys)
    cparams = {}
    for key in keys
      cparams[key] = params[key]
    end
    cparams
    #  cparams = {}
    #  cparams[:configurator_name] = params[:configurator_name]
  end

  def log_exception(e)
    e_str = e.to_s()
    e.backtrace.each do |bt|
      e_str += bt + ' \n'
    end
    @@last_error = e_str
    STDERR.puts e_str
    SystemUtils.log_output(e_str, 10)
    f = File.open('/tmp/exceptions.' + Process.pid.to_s, 'a+')
    f.puts(e_str)
    f.close
    return false
  end

  def log_error(*args)
    p :ERROR
    p args
    STDERR.puts args.to_s + '::' + @@core_api.last_error.to_s
    body args.to_s + ':' + @@core_api.last_error.to_s
    status(404)
    return false
  end

  def get_engine(engine_name)
    eng = @@core_api.loadManagedEngine(engine_name)
    return eng if eng.is_a?(ManagedEngine)
    log_error('Load failed !!!' + engine_name)
    return false
  end

  def get_service(service_name)
    service = @@core_api.loadManagedService(service_name)
    return service if service.is_a?(ManagedService)
    log_error('Load failed !!!' + service_name)
    return false
  end
rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)

end