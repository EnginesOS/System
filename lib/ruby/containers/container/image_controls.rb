module ImageControls
  def delete_image
    expire_engine_info
    r = true
    return log_error_mesg('Cannot Delete the Image while container exists. Please stop/destroy first',self) if has_container?
    r =  @container_api.delete_image(self)
    expire_engine_info
      r
   
  end

  def has_image?
    @container_api.image_exist?(@image)
  end

end