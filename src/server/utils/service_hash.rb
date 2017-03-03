module ServiceHash
  def self.service_hash_from_params(params, search)
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

  def self.engine_service_hash_from_params(params, search = false)
    hash = self.service_hash_from_params(params, search)
    hash[:parent_engine] = params['engine_name']
    hash[:container_type] = 'container'
    hash
  end

  def self.service_service_hash_from_params(params, search = false)
    hash = self.service_hash_from_params(params, search)
    hash[:parent_engine] = params['service_name']
    hash[:container_type] = 'service'
    return hash
  end

end