class EnvironmentVariable
  def initialize(name,value,setatrun,mandatory,build_time_only,label)
    @name=name
    @value=value
    @set_at_build_time=setatrun
    @build_time_only = build_time_only
    @mandatory = mandatory
    @setatrun = @set_at_build_time #Kludge so as noto break Guo should be removed when gui fixed
  end
  
  attr_reader :set_at_build_time,:name,:value,:build_time_only,:mandatory,:label,:setatrun
  
end