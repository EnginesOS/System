module  ServiceApiDockerActions
  def destroy_container(container)
    r = super
   
return r unless r == true
    @engines_core.clear_service_from_registry(container, :non_persistent)
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end
  
 
 
end