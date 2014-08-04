class SystemController < ApplicationController
  def index
    @snapshop = Vmstat::Snapshop.new()
  end
end
