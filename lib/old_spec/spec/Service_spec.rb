require_relative '../StaticService.rb'

require 'spec_helper'

describe StaticService do
  before :each do
    @service = StaticService.new("type")
  end
  
  describe "#new" do
         it "takes 1 arguments and returns StaticService Object" do
           @service.should be_an_instance_of StaticService
         end
     end
    describe "#serviceType" do
       it "Returns serviceType " do
         @service.serviceType.should eql "type"
       end
     end
end