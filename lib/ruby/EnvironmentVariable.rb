class EnvironmentVariable
  def initialize(name,value,setatrun)
    @name=name
    @value=value
    @setatrun=setatrun
  end
  
  attr_reader :setatrun,:name,:value
  
end