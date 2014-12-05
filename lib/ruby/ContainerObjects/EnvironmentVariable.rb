class EnvironmentVariable
  def initialize(name,value,setatrun)
    @name=name
    @value=value
    @setatrun=setatrun
    @build_time_only=false
  end
  
  attr_reader :setatrun,:name,:value,:build_time_only
  
end