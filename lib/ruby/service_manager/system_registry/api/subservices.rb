module Subservices

  #require_relative 'xcon_rset.rb'
  # Services Methods
  def all_subservices_registered_to(subservice_type)
    p = {}
    p[:subservice_type] = subservice_type
    rest_get('subservice/registered/engines/',{:params => p })
  end

  def find_subservice_consumers(subservice_query_hash)
    rest_get('subservice/consumers/',{:params => subservice_query_hash })
  end

  def update_attached_subservice(subservice_hash)
    rest_put('subservice/update', subservice_hash)
  end

  def add_to_subservices_registry(subservice_hash)
    rest_post('subservices/add',subservice_hash )
  end

  def remove_from_subservices_registry(subservice_hash)
    rest_delete('subservices/del',{:params => subservice_hash })
  end

  def subservice_is_registered?(subservice_hash)
    rest_get('subservice/is_registered',{:params => subservice_hash })
  end

  def get_subservice_entry(subservice_hash)
    rest_get('subservice/',{:params => subservice_hash })
  end

  def subservices_registry
    rest_get('subservices/tree', nil)
  end
end