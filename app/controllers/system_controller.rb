class SystemController < ApplicationController
  def index
    @stat=Vmstat::Snapshop.new()
  end
end
