module DockerApiImages
  def image_exist_by_name?(image_name)
    request = '/images/json?filter=' + image_name
    r =  get_request(request, true)
    if r.is_a?(Array)
      r = r[0]
      if r.is_a?(Hash) && r.key?(:Id)
        true
      else
        false
      end
    else
      false
    end
  end

  def find_images(search)
    request = '/images/json?filter=' + search
    r =  get_request(request, true)
    if r.is_a?(Array)
      r
    else
      false
    end
  end

  def pull_image(container)
    unless container.is_a?(String) # non app
      #container.image_repo = 'registry.hub.docker.com' if  container.image_repo.nil?
      #d = container.image
      tag= ''
      cd = container.image.split(':')
      d = cd[0]
      tag = cd[1] if cd.length > 1

      d = container.image_repo.to_s  + '/' + d unless container.image_repo.nil?
      request = '/images/create?fromImage=' + d.to_s
      request = request + '&tag=' + tag.to_s unless tag.nil?
    else # app
      cd = container.split(':')
      request = '/images/create?fromImage=' + cd[0]
      if tag.nil?
        tag = cd[1] if cd.length > 1
        tag.gsub!(/ /,'')
        tag.strip!
        request = request + '&tag=' + tag.to_s
      end
    end
    headers = { 'X-Registry-Config'  => registry_root_auth, 'Content-Type' =>'plain/text', 'Accept-Encoding' => 'gzip'}
    post_request(request, nil, false, headers, 600)
  rescue
    false #No new fresh ?
  end

  def image_exist?(container)
    if container.is_a?(String)
      image_exist_by_name?(container)
    else
      image_exist_by_name?(container.image)
    end
  rescue
    false
  end

  def delete_container_image(container)
    request = '/images/' + container.image
    thr = Thread.new {       
    delete_request(request)
    }
    thr[:name] = 'Docker delete container ' + container.image
  end

  def delete_image(image_name)
    thr = Thread.new {       
    request = '/images/' + image_name
    delete_request(request)}
      thr[:name] = 'Docker delete image:' + image_name.to_s
  end

  def clean_up_dangling_images
    thr = Thread.new {       
    images = find_images('dangling=true')
    unless images.is_a?(FalseClass)
      images.each do |image|
        next unless image.is_a?(Hash) && image.key?(:Id)
        @docker_comms.delete_image(image[:Id])
      end
    end }
    thr[:name] = 'clean_up_dangling_images:'
  end
end