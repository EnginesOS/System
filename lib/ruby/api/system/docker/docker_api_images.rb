module DockerApiImages
  def image_exist_by_name?(image_name)
    r =  get_request({uri: "/images/json?filter=#{image_name}"})
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
    r =  get_request({uri: "/images/json?filter=#{search}"})
    if r.is_a?(Array)
      r
    else
      false
    end
  end

  def pull_image(container)
    unless container.is_a?(String) # non app

      tag= ''
      cd = container.image.split(':')
      d = cd[0]
      tag = cd[1] if cd.length > 1

      d = "#{container.image_repo}/#{d}" unless container.image_repo.nil?
      request = "/images/create?fromImage=#{d}"
      request = "#{request}&tag=#{tag}" unless tag.nil?
    else # app
      cd = container.split(':')
      request = "/images/create?fromImage=#{cd[0]}"
      if tag.nil?
        tag = cd[1] if cd.length > 1
        tag.gsub!(/ /,'')
        tag.strip!
        request = "#{request}&tag=#{tag}"
      end
    end
    STDERR.puts(' Pulling ' + request.to_s)
    headers = { 'X-Registry-Config'  => registry_root_auth, 'Content-Type' =>'plain/text', 'Accept-Encoding' => 'gzip'}
    r = post({uri: request, expect_json: false, headers: headers, time_out: 600})
    STDERR.puts('Docker pull got' + r.to_s)
    r
  rescue StandardError =>e
    STDERR.puts('docker image pull got ' + e.to_s)
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
    request =
    thr = Thread.new {
      delete_request({uri: "/images/#{container.image}"})
    }
    thr[:name] = "Docker delete container #{container.image}"
  rescue StandardError => e
    SystemUtils.log_exception(e , 'delete_container_image:' + container.container_name)
    thr.exit unless thr.nil?
  end

  def delete_image(image_name, wait = false)
    thr = Thread.new { delete_request({uri: "/images/#{image_name}"}) }
    thr[:name] = "Docker delete image:#{image_name}"
    STDERR.puts( 'Docker Delete ' + '/images/' + image_name.to_s + ' Wiar? ' + wait.to_s)
    thr.join if wait == true
  rescue StandardError => e
    SystemUtils.log_exception(e , 'delete_image:' + image_name.to_s)
    thr.exit unless thr.nil?
  end

  def clean_up_dangling_images
    thr = Thread.new {
      images = find_images('dangling=true')
      unless images.is_a?(FalseClass)
        images.each do |image|
          next unless image.is_a?(Hash) && image.key?(:Id)
          delete_image(image[:Id])
        end
      end }
    thr[:name] = 'clean_up_dangling_images:'
  rescue StandardError => e
    SystemUtils.log_exception(e , 'clean_up_dangling_images:')
    thr.exit unless thr.nil?
  end
end