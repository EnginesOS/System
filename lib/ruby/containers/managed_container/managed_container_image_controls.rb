module ManagedContainerImageControls
  def delete_image()
    ret_val = false
    clear_error
    in_progress(:delete)
    super
  end

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image
    true
  end

end