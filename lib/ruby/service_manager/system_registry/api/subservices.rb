module Subsubservices

require_relative 'rset.rb'
# Services Methods

  def all_subservices_registered_to(subservice_type)
    p = {}
      p[:subservice_type] = subservice_type
    rest_get('/v0/system_registry/subservice/registered/engines/',{:params => p })
  end 
  
  
  def find_subservice_consumers(subservice_query_hash)
    rest_get('/v0/system_registry/subservice/consumers/',{:params => subservice_query_hash }) 
  end

  def update_attached_subservice(subservice_hash)
    rest_put('/v0/system_registry/subservice/update', subservice_hash)
  end

  def add_to_subservices_registry(subservice_hash)
    rest_post('/v0/system_registry/subservices/add',subservice_hash )
  end

  def remove_from_subservices_registry(subservice_hash)
    rest_delete('/v0/system_registry/subservices/del',{:params => subservice_hash })
  end

  def subservice_is_registered?(subservice_hash)
    rest_get('/v0/system_registry/subservice/is_registered',{:params => subservice_hash })
  end

 
  

  def get_subservice_entry(subservice_hash)
    rest_get('/v0/system_registry/subservice/',{:params => subservice_hash })
  end

  
def subservices_registry
   rest_get('/v0/system_registry/subservices/tree', nil)
 end
end