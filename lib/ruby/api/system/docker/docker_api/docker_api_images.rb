module DockerApiImages
  def image_exist_by_name?(image_name)
    request = '/images/json?filter=' + image_name
    r =  get_request(request, true)
    return  false unless r.is_a?(Array)
    r = r[0]
    return true if r.is_a?(Hash) && r.key?(:Id)
    false
  end

  def find_images(search)
    request = '/images/json?filter=' + search
    r =  get_request(request, true)
    return  false unless r.is_a?(Array)
    r
  end

  def pull_image(container)
    unless container.is_a?(String)
      #container.image_repo = 'registry.hub.docker.com' if  container.image_repo.nil?
      d =  container.image
      d = container.image_repo.to_s  + '/' + d unless container.image_repo.nil?
      request =  '/images/create?fromImage=' + d.to_s
    else
      request =  '/images/create?fromImage=' + container
      container = nil
    end

    headers = { 'X-Registry-Config'  => get_registry_auth, 'Content-Type' =>'plain/text', 'Accept-Encoding' => 'gzip'}
    post_request(request,  nil, false , headers ,600)
  end

  def image_exist?(container)
    return image_exist_by_name?(container) if container.is_a?(String)
    image_exist_by_name?(container.image)
  rescue
    false
  end

  def delete_container_image(container)
    request = '/images/' + container.image
    delete_request(request)
  end

  def delete_image(image_name)
    request = '/images/' + image_name
    delete_request(request)
  end
end