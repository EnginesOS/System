module ManagedServiceImageControls
  def deleteimage
    raise EnginesException.new(error_hash('Cannot call delete image on a service', container_name))
    # noop never do  this as need buildimage again or only for expert
  end

  def pull_image
    raise EnginesException.new(error_hash('no Repo URI' + image)) if @repository.nil? && ! image.include?('/')
    @container_api.pull_image(self)
  end

end