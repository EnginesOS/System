class SystemApi
  def get_build_report(engine_name)
    raise EnginesException.new(error_hash('get_build_report passed nil engine_name', engine_name)) if engine_name.nil?
    ContainerStateFiles.get_build_report(engine_name)
  end

end