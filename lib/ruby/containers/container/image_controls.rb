module ImageControls
  def delete_image
    expire_engine_info
    r = true
    raise EnginesException.new(warning_hash('Cannot Delete the Image while container exists. Please stop/destroy first', self)) if has_container?
    begin
      r =  @container_api.delete_image(self)
    ensure
      expire_engine_info
    end
    r
  end

  def has_image?
    @container_api.image_exist?(@image)
  end

end