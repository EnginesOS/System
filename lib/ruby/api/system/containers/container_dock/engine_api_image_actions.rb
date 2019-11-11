require '/opt/engines/lib/ruby/containers/store/cache'

module EngineApiImageActions
  def delete_image(container, wait=true)
    clear_error
    Container::Cache.instance.remove(container.container_name)
    dock_face.delete_image(container.image, wait) if dock_face.image_exist?(container.image)
  end
end
