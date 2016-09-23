module  ServiceApiDockerActions
  def destroy_container(container)
    r =''
return r (r = super) unless r == true
    @engines_core.clear_service_from_registry(self, :non_persistent)
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end
  
 
 
end