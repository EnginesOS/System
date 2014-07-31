require "/opt/mpas/lib/ruby/ManagedContainer.rb"
require "/opt/mpas/lib/ruby/SysConfig.rb"

class EnginesController < ApplicationController
  
  def index
    @engines = ManagedContainer.getManagedContainers("container")
      if @engines == nil
        @result =false
      else
        @result = true
      end
  end
  
  def show
    @engine = ManagedContainer.load("container",params[:id])
      if @engine == nil
        @result =false
      else
        @result =true
      end
  end
  
  def stop
    @engine = ManagedContainer.load("container",params[:id])
    @result = @engine.stop_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def start
    @engine = ManagedContainer.load("container",params[:id])
    @result =  @engine.start_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def pause
    @engine = ManagedContainer.load("container",params[:id])
    @result = @engine.pause_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def unpause
     @engine = ManagedContainer.load("container",params[:id])
     @result = @engine.unpause_container
    redirect_to engine_path(@engine.containerName)
   end
   
  def destroy_engine
    @engine = ManagedContainer.load("container",params[:id])
    @result =@engine.destroy_container
    redirect_to engine_path(@engine.containerName)
  end 
  
  def deleteimage
    @engine = ManagedContainer.load("container",params[:id])
      if (@engine)      
        @result =@engine.delete_image        
        redirect_to engine_path(@engine.containerName)
      end #FIX ME Need to go some
  end 
  
  def restart
    @engine = ManagedContainer.load("container",params[:id])
    @result = @engine.restart_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def create_engine
    @engine = ManagedContainer.load("container",params[:id])
        @result = @engine.create_container
        redirect_to engine_path(@engine.containerName)
  end

  def monitor
    @engine = ManagedContainer.load("container",params[:id])
            @result = @engine.monitor_site
            redirect_to engine_path(@engine.containerName)
  end
  
  def demonitor
    @engine = ManagedContainer.load("container",params[:id])
            @result = @engine.demonitor_site
            redirect_to engine_path(@engine.containerName)
  end
  
  def register_site
    @engine = ManagedContainer.load("container",params[:id])
                @result = @engine.register_site
                redirect_to engine_path(@engine.containerName)
  end
  
  def deregister_site
    @engine = ManagedContainer.load("container",params[:id])
                @result = @engine.deregister_site
                redirect_to engine_path(@engine.containerName)
  end
  
  def edit
    @engine = ManagedContainer.load("container",params[:id])
      #only on nocontainer but with image 
      #will trigger a create
  end
  
end
