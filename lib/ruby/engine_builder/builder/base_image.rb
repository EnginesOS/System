def read_base_image_from_dockerfile
  dockerfile = File.open(basedir + '/Dockerfile', 'r')
  begin
    from_line = dockerfile.gets("\n", 100)
    from_line.gsub!(/^FROM[ ]*/, '')
  ensure
    dockerfile.close
  end
  from_line
end

def get_base_image
  base_image_name = read_base_image_from_dockerfile
  raise EngineBuilderException.new(error_hash('Failed to Read Image from Dockerfile')) if base_image_name.nil?
  log_build_output('Pull base Image: ' + base_image_name.to_s)
  @core_api.pull_image(base_image_name) #== false
  true
rescue StandardError => e
  log_build_errors(e)
  raise e if e.is_a?(EngineBuilderException)
  # FIXME:
  # Buggy so ignore when fails
  true
end
