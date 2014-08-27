
require "EnginesOSapi.rb"

class EnginesController < ApplicationController
  before_action :authenticate_user!
  

  
  def index
    @result =false
    @engines = @enginesOS_api.getManagedEngines()
      if @engines != nil
        @result = true      
      end
      
  end
  
  def show
    @result =false
    @engine = @enginesOS_api.loadManagedEngine(params[:id])
      if @engine != nil
        @result = true
      end
  end
  
  def stop   
    @result = @enginesOS_api.stopEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def start   
    @result = @enginesOS_api.startEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def pause
    @result = @enginesOS_api.pauseEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def unpause
    @result = @enginesOS_api.unpauseEngine(params[:id])
    redirect_to engine_path(params[:id])
   end
   
  def destroy_engine
    @result = @enginesOS_api.destroyEngine(params[:id])
    redirect_to engines_path
  end 
  
  def deleteimage
    @result = @enginesOS_api.deleteEngineImage(params[:id])
    redirect_to engines_path

  end 
  
  def restart
    @result = @enginesOS_api.restartEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def create_engine
    @result = @enginesOS_api.createEngine(params[:id])
   redirect_to engine_path(params[:id])
  end

  def monitor
    @result = @enginesOS_api.monitorEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def demonitor
    @result = @enginesOS_api.demonitorEngine(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def register_site
    @result = @enginesOS_api.registerEngineWebSite(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def deregister_site
    @result = @enginesOS_api.deregisterEngineWebSite(params[:id])    
     redirect_to engine_path(params[:id])
  end
  
  def register_dns
    @result = @enginesOS_api.registerEngineDNS(params[:id])
    redirect_to engine_path(params[:id])
  end
  
  def deregister_dns
    @result = @enginesOS_api.deregisterEngineDNS(params[:id])    
     redirect_to engine_path(params[:id])
  end
   
  def edit
       @engine = @enginesOS_api.loadManagedEngine(params[:id])
         #FIXME still to do
      #only on nocontainer but with image 
      #will trigger a create
  end
  
end
