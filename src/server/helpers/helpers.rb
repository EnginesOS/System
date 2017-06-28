helpers do
  require_relative 'params.rb'
  require_relative 'output.rb'
  require_relative 'errors.rb'
  require_relative 'warden/warden_config.rb'
  def engines_api
    #$engines_api
    $engines_api ||= PublicApi.new(core_api)
  end

  def json_parser
    # @json_parser = Yajl::Parser.new(:symbolize_keys => true) if @json_parser.nil?
    @json_parser ||= FFI_Yajl::Parser.new(symbolize_keys: true)
  end

  def get_engine(engine_name)
    engines_api.loadManagedEngine(engine_name)
  end

  def get_utilty(utilty_name)
    engines_api.loadManagedUtilty(utilty_name)
  end

  def get_service(service_name)
    engines_api.loadManagedService(service_name)
  end

  def downcase_keys(hash)
    unless hash.is_a?(Hash)
      hash
    else
      hash.map{|k, v| [k.downcase, downcase_keys(v)]}.to_h
    end
  end

  def managed_containers_to_json(containers)
    return_json_array(containers, 404) if containers.nil?
    if containers.is_a?(Array)
      res = []
      containers.each do |c|
        res.push(c.to_h)
      end
      return_json_array(res)
    else
      return_json(c.to_h)
    end
  end

  def managed_container_as_json(c)
    return_json(c.to_h)
  end

end
