class  EnginesOSapiResult
    
    def initialize(item_name,cmd)
        @was_sucess=true
        @result_code = 0
        @item_name = item_name      
        @result_mesg = "OK"
        @action = cmd
      end
      
    def initialize(result,code,item_name, msg,cmd)
      @was_sucess=result
      @result_code = code
      @item_name = item_name
      @result_mesg = msg
      @action = cmd
    end
      
    def was_sucess
      return @was_sucess
    end
    def result_code
      return @result_code
    end
    def item_name
      return @item_name
    end
    def result_mesg
      return @result_mesg
    end
    def action
      return @action
    end
  end
