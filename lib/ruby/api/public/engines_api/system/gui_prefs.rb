module GuiPrefs
  
  def set_container_icon_url(container, url)
    url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'w+')
    url_f.puts(url)    
    url_f.close
  end
  
  def container_icon_url(container)
    url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'r')
      url = url_f.gets(url)
      url_f.close
      url.strip!    
    end
    
end