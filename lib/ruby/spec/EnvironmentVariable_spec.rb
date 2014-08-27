require_relative '../EnvironmentVariable.rb'

require 'spec_helper'

describe EnvironmentVariable do
  before :each do
    @environmentvariable = EnvironmentVariable.new("name","value",true)
  end
  
  describe "#new" do
       it "takes 4 arguments and returns container Object" do
         @environmentvariable.should be_an_instance_of EnvironmentVariable
       end
   end
  describe "#name" do
      it "Returns name " do
        @environmentvariable.name.should eql "name"
      end
    end
  describe "#value" do
      it "Returns value " do
        @environmentvariable.value.should eql "value"
      end
    end
    
  describe "#setatrun" do
       it "Returns setatrun " do
         @environmentvariable.setatrun.should eql true
       end
     end
end