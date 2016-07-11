module DockerApiImages
  def image_exist_by_name?(image_name)
    request = '/images/json?filter=' + image_name
    r =  get_request(request, true)
    return  false unless r.is_a?(Array)
    r = r[0]
    return true if r.is_a?(Hash) && r.key?('Id')

    return  false
  rescue StandardError => e
    log_exception(e)
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
    STDERR.puts(' pull  ' + request.to_s)
    headers = { 'X-Registry-Config'  => get_registry_auth, 'Content-Type' =>'plain/text', 'Accept-Encoding' => 'gzip'}
    r =  post_request(request,  nil, false , headers )
#    req = Net::HTTP::Post.new(request, header)
#   r = perform_request(req, container, false,  false)
#    
    STDERR.puts(' pull result ' + r.to_s)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def  image_exist?(container)
    return image_exist_by_name?(container) if container.is_a?(String)
    return image_exist_by_name?(container.image)
    #    request = '/images/' + container.image + '/json'
    #    r =  get_request(request,true)
    #    return true if r.is_a?(Hash) && r.key?('Id')
    #    STDERR.puts(' image_exist? res ' + r.to_s )
    #    return  false
  rescue StandardError => e
    log_exception(e)
  end

  def delete_container_image(container)
    request = '/images/' + container.image
    return delete_request(request)
  rescue StandardError => e
    log_exception(e)
  end

  def delete_image(image_name)
    request = '/images/' + image_name
    return delete_request(request)
  rescue StandardError => e
    log_exception(e)
  end
end