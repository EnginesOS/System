class SystemController < ApplicationController
  def index
    @snapshop = Vmstat.snapshot
    sleep 1
    @vm2 = Vmstat.memory
  end
end
