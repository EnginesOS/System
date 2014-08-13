require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/SysConfig.rb"
require "/opt/engos/lib/ruby/ManagedEngine.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
require "/opt/engos/lib/ruby/NginxService.rb"
require "/opt/engos/lib/ruby/NagiosService.rb"

class EnginesController < ApplicationController
  before_action :authenticate_user!
  def index
    @engines = ManagedEngine.getManagedEngines()
      if @engines == nil
        @result =false
      else
        @result = true
      end
  end
  
  def show
    @engine = ManagedEngine.load(params[:id])
      if @engine == nil
        @result =false
      else
        @result =true
      end
  end
  
  def stop
    @engine = ManagedEngine.load(params[:id])
    @result = @engine.stop_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def start
    @engine = ManagedEngine.load(params[:id])
    @result =  @engine.start_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def pause
    @engine = ManagedEngine.load(params[:id])
    @result = @engine.pause_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def unpause
    @engine = ManagedEngine.load(params[:id])
     @result = @engine.unpause_container
    redirect_to engine_path(@engine.containerName)
   end
   
  def destroy_engine
    @engine = ManagedEngine.load(params[:id])
    @result =@engine.destroy_container
    redirect_to engine_path(@engine.containerName)
  end 
  
  def deleteimage
    @engine = ManagedEngine.load(params[:id])
      if (@engine)      
        @result =@engine.delete_image        
        redirect_to engine_path(@engine.containerName)
      end #FIX ME Need to go some
  end 
  
  def restart
    @engine = ManagedEngine.load(params[:id])
    @result = @engine.restart_container
    redirect_to engine_path(@engine.containerName)
  end
  
  def create_engine
    @engine = ManagedEngine.load(params[:id])
        @result = @engine.create_container
        redirect_to engine_path(@engine.containerName)
  end

  def monitor
    @engine = ManagedEngine.load(params[:id])
            @result = @engine.monitor_site
            redirect_to engine_path(@engine.containerName)
  end
  
  def demonitor
    @engine = ManagedEngine.load(params[:id])
            @result = @engine.demonitor_site
            redirect_to engine_path(@engine.containerName)
  end
  
  def register_site
       @engine = ManagedEngine.load(params[:id])
                @result = @engine.register_site
                redirect_to engine_path(@engine.containerName)
  end
  
  def deregister_site
       @engine = ManagedEngine.load(params[:id])
                @result = @engine.deregister_site
                redirect_to engine_path(@engine.containerName)
  end
  
  def edit
       @engine = ManagedEngine.load(params[:id])
      #only on nocontainer but with image 
      #will trigger a create
  end
  
end
