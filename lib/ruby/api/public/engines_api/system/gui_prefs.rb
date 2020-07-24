class PublicApi 
  def set_container_icon_url(ca, url)
    ContainerStateFiles.set_container_icon_url(ca, url)
  end

  def container_icon_url(ca)
    ContainerStateFiles.container_icon_url(ca)
  end
end