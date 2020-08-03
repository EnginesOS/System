require '/opt/engines/lib/ruby/containers/store/cache'

class ContainerApi
  def delete_image(container, wait=true)
    clear_error
    Container::Cache.instance.remove(container.container_name)
    docker_api.delete_image(container.image, wait) if docker_api.image_exist?(container.image)
  end
end
