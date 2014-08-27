require_relative '../WorkPort.rb'

require 'spec_helper'

describe WorkPort do
  before :each do
    @workport = WorkPort.new("name",88,88,true)
  end
  
  describe "#new" do
       it "takes 4 arguments and returns workport Object" do
         @workport.should be_an_instance_of WorkPort
       end
   end
  describe "#name" do
     it "Returns name " do
       @workport.name.should eql "name"
     end
   end
  describe "#port" do
       it "Returns port " do
         @workport.port.should eql 88
       end
     end
  describe "#external" do
        it "Returns external " do
          @workport.external.should eql 88
        end
      end  
  describe "#publicFacing" do
         it "Returns publicFacing " do
           @workport.publicFacing.should eql true
         end
       end  
        
   
end