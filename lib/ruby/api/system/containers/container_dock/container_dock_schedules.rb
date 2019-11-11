module ContainerDockSchedules
  def schedules(c)
    system_api.schedules(c)
  end

  def apply_schedules(c)
    system_api.apply_schedules(c)
  end
  def remove_schedules(c)
     system_api.remove_schedules(c)
   end
end