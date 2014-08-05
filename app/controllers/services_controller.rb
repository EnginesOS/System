require "/opt/mpas/lib/ruby/ManagedContainer.rb"
require "/opt/mpas/lib/ruby/ManagedService.rb"
require "/opt/mpas/lib/ruby/NginxService.rb"
require "/opt/mpas/lib/ruby/NagiosService.rb"

class ServicesController < ApplicationController
  def index
    @services = ManagedService.getManagedServices()
           if @services == nil
             @result =false
           else
             @result = true
           end
  end
  def show
      @service = ManagedService.load(params[:id])
        if @service == nil
          @result =false
        else
          @result =true
        end
    end
    
    def stop
      @service = ManagedService.load(params[:id])
          @result = @service.stop_container
          redirect_to service_path(@service.containerName)
    end
   def start
       @service = ManagedService.load(params[:id])
           @result = @service.start_container
           redirect_to service_path(@service.containerName)
   end
     
    def pause
      @service = ManagedService.load(params[:id])
      @result = @service.pause_container
      redirect_to service_path(@service.containerName)
    end
    
    def unpause
      @service = ManagedService.load(params[:id])
      @result = @service.unpause_container
      redirect_to service_path(@service.containerName)
    end
    
  def register_site
        @service = ManagedService.load(params[:id])
                 @result = @service.register_site
                 redirect_to service_path(@service.containerName)
   end
   
   def deregister_site
        @service = ManagedService.load(params[:id])
                 @result = @service.deregister_site
                 redirect_to service_path(@service.containerName)
   end
   
  def create_service
    @service = ManagedService.load(params[:id])      
        @result = @service.create_service
        redirect_to service_path(@service.containerName)
  end

    
    def recreate 
      @service = ManagedService.load(params[:id])
      @service.recreate
    end
end
