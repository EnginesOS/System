module PublicApiSystemControlBaseOS
  def update_base_os
    @system_api.update_base_os
  end

  def restart_base_os
    @system_api.restart_base_os
  end

  def halt_base_os
    @system_api.halt_base_os
  end
  def set_locale(locale)
     @system_api.set_locale(locale)
   end
   
   def set_timezone(tz)
     @system_api.set_timezone(tz)
   end
   
   def get_locale
     @system_api.get_locale
   end
   
   def get_timezone
     @system_api.get_timezone
   end
end

