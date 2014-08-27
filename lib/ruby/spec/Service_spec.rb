require_relative '../Service.rb'

require 'spec_helper'

describe Service do
  before :each do
    @service = Service.new("type")
  end
  
  describe "#new" do
         it "takes 1 arguments and returns Service Object" do
           @service.should be_an_instance_of Service
         end
     end
    describe "#serviceType" do
       it "Returns serviceType " do
         @service.serviceType.should eql "type"
       end
     end
end