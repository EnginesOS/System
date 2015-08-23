require_relative '../StaticService.rb'
require_relative '../DatabaseService.rb'

require 'spec_helper'

describe DatabaseService do
  before :each do
    @database = DatabaseService.new("name","host","user","pass","flavor")
  end
  
  describe "#new" do
         it "takes 5 arguments and returns Service Object" do
           @database.should be_an_instance_of DatabaseService
         end
     end
    describe "#serviceType" do
       it "Returns serviceType " do
         @database.serviceType.should eql "database"
       end
     end
     
  describe"#name" do
  it "Returns name " do
    @database.name.should eql "name"
  end
end
  describe"#dbHost" do
   it "Returns dbHost " do
     @database.dbHost.should eql "host"
   end
 end
  describe"#dbUser" do
    it "Returns dbUser " do
      @database.dbUser.should eql "user"
    end
  end

  describe"#dbPass" do
     it "Returns dbPass " do
       @database.dbPass.should eql "pass"
     end
   end
  describe"#flavor" do
       it "Returns flavor " do
         @database.flavor.should eql "flavor"
       end
     end
end