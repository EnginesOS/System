require_relative '../ContainerStatistics.rb'
require 'spec_helper'

describe ContainerStatistics do
  before :each do  
    @statistics = ContainerStatistics.new("state",1,"started_ts","stopped_ts",100,100,1)    
  end
  
  describe "#new" do
        it "takes 5 arguments and returns ContainerStatistics Object" do
          @statistics.should be_an_instance_of ContainerStatistics
        end
    end
  describe "#state" do
      it "Returns state " do
        @statistics.state.should eql "state"
      end
    end   
  describe "#proc_cnt" do
       it "Returns proc_cnt " do
         @statistics.proc_cnt.should eql 1
       end
     end  
  describe "#stopped_ts" do
       it "Returns stopped_ts " do
         @statistics.stopped_ts.should eql "stopped_ts"
       end
     end     
  describe "#started_ts" do
       it "Returns started_ts " do
         @statistics.started_ts.should eql "started_ts"
       end
     end                
  describe "#VSSMemory" do
         it "Returns VSSMemory " do
           @statistics.VSSMemory.should eql 100
         end
       end  
  describe "#RSSMemory" do
           it "Returns RSSMemory " do
             @statistics.RSSMemory.should eql 100
           end
         end 
  describe "#cpuTime" do
            it "Returns cpuTime " do
              @statistics.cpuTime.should eql 1
            end
          end     
end