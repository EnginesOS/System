class SystemController < ApplicationController
  def index
    @stat=Vmstat.snapshop.new()
  end
end
