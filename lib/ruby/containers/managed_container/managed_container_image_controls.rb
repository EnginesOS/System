module ManagedContainerImageControls
  def delete_image()
    return false unless has_api?
    ret_val = false
    clear_error
    in_progress(:delete)
    r =  super
    @last_task =  @task_at_hand
    @task_at_hand = nil
    return r
  end

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image
    return true
  end

end