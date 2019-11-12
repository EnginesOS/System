module ServiceDockImageActions
  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    dock_face.pull_image(image_name)
    begin
      remove_old(image_name)
    rescue #might be in use for another container or image
      true
    end
    true
  rescue
    false
  end

  private

  def remove_old(image)
    image_name = name.sub(/:.*/,':none')

    if image_exist_by_name?(image_name)
      delete_image(image_name)
    end
  end

  def old_tag(image_name)
    image_name.sub(/:.*/,':none')
  end
end
