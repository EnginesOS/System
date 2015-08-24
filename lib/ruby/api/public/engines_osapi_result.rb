class  EnginesOSapiResult
  
  attr_reader :was_success,:result_code,:result_mesg,:item_name,:action
    
    def initialize(item_name,cmd)
        @was_success=true
        @result_code = 0
        @item_name = item_name      
        @result_mesg = 'Success'
        @action = cmd
      end
      
    def initialize(result,code,item_name, msg,cmd)
      @was_success=result
      @result_code = code
      @item_name = item_name
      @result_mesg = msg
      @action = cmd
    end
    
  def EnginesOSapiResult.success(item_name ,cmd)
     return  EnginesOSapiResult.new(true,0,item_name, 'Success',cmd)
   end
 
   def EnginesOSapiResult.failed(item_name,mesg ,cmd)
     return  EnginesOSapiResult.new(false,-1,item_name, mesg.to_s,cmd)
   end
 
  end
