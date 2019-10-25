module GuiPrefs
  def set_container_icon_url(container, url)
    SystemPreferences.set_container_icon_url(container, url)
  end

  def container_icon_url(container)
    SystemPreferences.container_icon_url(container)
  end
end