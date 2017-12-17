module GuiPrefs
  def set_container_icon_url(container, url)
    SystemPreferences.set_container_icon_url(container, url)
#    url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'w+')
#    url_f.puts(url)
#    url_f.close
#  rescue StandardError => e
#    url_f.close unless url_f.nil?
#    raise e
  end

  def container_icon_url(container)
    SystemPreferences.container_icon_url(container)
#   if File.exists?(ContainerStateFiles.container_state_dir(container) + '/icon.url')
#    url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'r')
#    url = url_f.gets(url)
#    url_f.close
#    url.strip
#   else
#     nil
#   end
#  rescue StandardError => e
#    url_f.close unless url_f.nil?
#    raise e
  end
end