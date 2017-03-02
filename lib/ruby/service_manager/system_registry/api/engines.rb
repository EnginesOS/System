module Engines
#  require_relative 'xcon_rset.rb'
  # engines Methods
  def find_engine_service_hash(params)
    SystemDebug.debug(SystemDebug.services,'sm find_engine_service_hash  ', params)
    r = '/v0/system_registry/engine/service/'  + params[:container_type] + '/' + params[:parent_engine] 
       r += '/' + params[:service_handle] 
       r += '/' + params[:type_path] 
       rest_get(r)
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/engine/service/ ' + params.to_s)
        SystemUtils.log_exception(e)
      
  end

  def find_engine_services_hashes(params)
  #  rest_get('/v0/system_registry/engine/services/',{:params => params })
  r = '/v0/system_registry/engine/services/'  + params[:container_type] + '/' + params[:parent_engine] 
    r += '/' + params[:type_path] if params.key?(:type_path)
    rest_get(r)
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/engine/services/ ' + params.to_s)
        SystemUtils.log_exception(e)
      
  end

  def get_engine_nonpersistent_services(params)
    params[:persistent] = false
    rest_get('/v0/system_registry/engine/services/nonpersistent/',{:params => params })
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/engine/services/nonpersistent/  ' + params.to_s)
        SystemUtils.log_exception(e)
      
  end

  def get_engine_persistent_services(params)
    params[:persistent] = true
    rest_get('/v0/system_registry/engine/services/persistent/',{:params => params })
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/engine/services/persistent/  ' + params.to_s)
        SystemUtils.log_exception(e)
      
  end

  def add_to_managed_engines_registry(service_hash)
    SystemDebug.debug(SystemDebug.services,'sm add_to_managed_engines_registry ', service_hash)
    rest_post('/v0/system_registry/engine/services/add',service_hash )
  rescue StandardError => e
    STDERR.puts( 'Failed To /v0/system_registry/engine/services/add  ' + service_hash.to_s)
     SystemUtils.log_exception(e)
  end

  def remove_from_managed_engines_registry(params)
      params[:container_type] = 'container' unless params.key?(:container_type) || 
    r = '/v0/system_registry/engine/services/del/ '  + params[:container_type] + '/' + params[:parent_engine] 
          r += '/' + params[:service_handle] 
          r += '/' + params[:type_path] 
    rest_delete(r) 
   # rest_delete('/v0/system_registry/engine/services/del',{:params => params })
        rescue StandardError => e
           STDERR.puts( 'Failed To /v0/system_registry/engine/services/del/  ' + params.to_s)
            SystemUtils.log_exception(e)
          
  end

  def update_registered_managed_engine(params)
    r = '/v0/system_registry/engine/services/update/'  + params[:container_type] + '/' + params[:parent_engine] 
             r += '/' + params[:service_handle] 
             r += '/' + params[:type_path] 
    rest_put(r,{:api_vars => params })
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/engine/services/update/  ' + params.to_s)
        SystemUtils.log_exception(e)
      
  end

  def managed_engines_registry
    rest_get('/v0/system_registry/engines/tree', nil)
  end

end