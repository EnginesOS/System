module ManagedServiceImageControls
  def deleteimage
    log_error_mesg('Cannot call delete image on a service',self)
    # noop never do  this as need buildimage again or only for expert
  end

  def pull_image
    return log_error_mesg('no repo' + image) if @repository.nil? && ! image.include?('/')
    return @container_api.pull_image(self)
  end

end