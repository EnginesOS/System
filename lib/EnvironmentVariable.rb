class EnvironmentVariable
  def initialize(name,value,setatrun)
    @name=name
    @value=value
    @setatrun=setatrun
  end
  def setatrun
    return @setatrun
  end
  def name
    return @name
  end
  def value
    return @value
  end
end