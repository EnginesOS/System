require "/opt/mpas/lib/ruby/ManagedContainer.rb"
require "/opt/mpas/lib/ruby/SysConfig.rb"

class EnginesController < ApplicationController
  def index
    @engines = ManagedContainer.getManagedContainers("container")
  end
end
