class  EnginesOSapiResult
  
  attr_reader :was_success,:result_code,:result_mesg,:item_name,:action
    
    def initialize(item_name,cmd)
        @was_success=true
        @result_code = 0
        @item_name = item_name      
        @result_mesg = "OK"
        @action = cmd
      end
      
    def initialize(result,code,item_name, msg,cmd)
      @was_success=result
      @result_code = code
      @item_name = item_name
      @result_mesg = msg
      @action = cmd
    end
    
 
  end
