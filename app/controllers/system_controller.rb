class SystemController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @snapshop = Vmstat.snapshot
    sleep(1) #FIXME this is a kludge need to use time stamps and do a wait for or something better then just sleep?
    @vm2 = Vmstat.memory
  end
end
