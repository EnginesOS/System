module GuiPrefs
  def set_container_icon_url(ca, url)
    SystemPreferences.set_container_icon_url(ca, url)
  end

  def container_icon_url(ca)
    SystemPreferences.container_icon_url(ca)
  end
end