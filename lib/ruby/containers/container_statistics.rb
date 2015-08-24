class ContainerStatistics

    def initialize(state,pcnt,started,stopped,rss,vss,cpu)
      @state = state #string
      @proc_cnt = pcnt 
      @started_ts = started # formated as
      @stopped_ts = stopped
      @RSSMemory = rss
      @VSSMemory = vss
      @cpuTime = cpu
    end
    
    def state
      return @state      
    end
    
    def proc_cnt
      return @proc_cnt
    end
    
    def started_ts
      return @started_ts
    end
    
    def stopped_ts
      return @stopped_ts
    end
     def VSSMemory
        return @VSSMemory
      end
    def RSSMemory
      return @RSSMemory
    end
    
    def cpuTime
      return @cpuTime
    end
end  
