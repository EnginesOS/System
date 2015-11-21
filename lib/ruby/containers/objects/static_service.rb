class StaticService
  def initialize(type)
    @serviceType = type
  end

  def serviceType
    return @serviceType
  end
end