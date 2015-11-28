module ManagedContainerImageControls
  def delete_image()
    return false unless has_api?
    ret_val = false
    clear_error
    in_progress(:delete)
    r =  super   
    return r
  end

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image
    return true
  end

end