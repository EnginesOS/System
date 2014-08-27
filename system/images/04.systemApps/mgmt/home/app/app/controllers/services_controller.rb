

require "EnginesOSapi.rb"

class ServicesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @services = enginesOS_api.getManagedServices()
           if @services == nil
             @result =false
           else
             @result = true
           end
  end
  def show
      @service = enginesOS_api.loadManagedService(params[:id])
        if @service == nil
          @result =false
        else
          @result =true
        end
    end
    
    def stop
       @result = @enginesOS_api.stopService params[:id]
       redirect_to service_path(params[:id])
    end
   def start
       @result = @enginesOS_api.startService params[:id]
       redirect_to service_path(params[:id])
   end
     
    def pause
      @result = @enginesOS_api.pauseService params[:id]
      redirect_to service_path(params[:id])
    end
    
    def unpause
      @result = @enginesOS_api.unpauseService params[:id]
       redirect_to service_path(params[:id])
    end
    
  def register_site
        @result = @enginesOS_api.registerServiceWebSite params[:id]
        redirect_to service_path(params[:id])
   end
   
   def deregister_site
     @result = @enginesOS_api.deregisterServiceWebSite params[:id]
     redirect_to service_path(params[:id])
   end
  def register_dns
        @result = @enginesOS_api.registerServiceDNS params[:id]
        redirect_to service_path(params[:id])
   end
   
   def deregister_dns
     @result = @enginesOS_api.deregisterServiceDNS params[:id]
     redirect_to service_path(params[:id])
   end
  def create_service     
    @result = @enginesOS_api.createService params[:id]
    redirect_to service_path(params[:id])
  end

    
    def recreate 
      @result = @enginesOS_api.recreateService params[:id]
      redirect_to service_path(params[:id]) 
    end
end
