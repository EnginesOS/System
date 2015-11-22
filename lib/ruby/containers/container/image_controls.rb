module ImageControls
  def delete_image
    expire_engine_info
    r = true
    return log_error_mesg('Cannot Delete the Image while container exists. Please stop/destroy first',self) if has_container?
    r = false unless @container_api.delete_image(self)
    expire_engine_info
    return true if r
    return log_error_mesg('Can\'t delete image', @container_api.last_error)
  end

  def has_image?
    @container_api.image_exist?(@image)
  end

end