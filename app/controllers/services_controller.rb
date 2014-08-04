
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
end
