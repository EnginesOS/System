class SystemController < ApplicationController
  def index
    @snapshop = Vmstat.snapshot
  end
end
