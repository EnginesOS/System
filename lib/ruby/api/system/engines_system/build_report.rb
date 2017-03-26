module BuildReport
  class FakeContainer
    attr_reader :container_name, :ctype
    def initialize(name, type = 'container')
      @container_name = name
      @ctype = type
    end
  end
  def get_build_report(engine_name)
    clear_error
    raise EnginesException.new(error_hash('get_build_report passed nil engine_name', engine_name)) if engine_name.nil?
    c = container_state_dir(FakeContainer.new(engine_name))
    File.read(c + '/buildreport.txt') if File.exist?(c + '/buildreport.txt')
    raise EnginesException.new(error_hash('No Build Report:' + c + '/buildreport.txt'))
  end

  def save_build_report(container, build_report)
    clear_error
    f = File.new(container_state_dir(container) + '/buildreport.txt', File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(build_report)
    f.close
    true
  end

end