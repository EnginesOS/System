module ServiceHash
  def self.service_hash_from_params(params, search)
    splats = params['splat']

    hash = {}
    hash[:publisher_namespace] = params['publisher_namespace']

    unless search
      hash[:type_path] = File.dirname(splats[0])
      hash[:service_handle] = File.basename(splats[0])
    else
      hash[:type_path] =  splats[0]
    end
    hash
  end

  def self.engine_service_hash_from_params(params, search = false)
    p :params
    p params
    hash = self.service_hash_from_params(params, search)
    hash[:parent_engine] = params['engine_name']
    hash[:container_type] = 'container'
    hash
  end

  def self.service_service_hash_from_params(params, search = false)
    p :params
    p params
    hash = self.service_hash_from_params(params, search)
    hash[:parent_engine] = params['service_name']
    hash[:container_type] = 'service'
    return hash
  end

end