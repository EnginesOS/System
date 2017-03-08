module ContainerApiSchedules
  def schedules(container)
    @system_api.schedules(container)
  end

  def apply_schedules(container)
    @system_api.apply_schedules(container)
  end

end