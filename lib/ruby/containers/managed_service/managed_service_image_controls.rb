module ManagedServiceImageControls
  def deleteimage
    log_error_mesg('Cannot call deleteimage on a service',self)
    # noop never do  this as need buildimage again or only for expert
  end

  def pull_image
    return @container_api.pull_image(@repository + '/' + image) unless @repository.nil? || @repository == ''
    return @container_api.pull_image(image) if image.include?('/')
    return false
  end

end