require_relative '../PermissionRights.rb'

require 'spec_helper'

describe PermissionRights do
  before :each do
    @permission_rights = PermissionRights.new("owner","ro_group","rw_group")
  end
  
  describe "#new" do
       it "takes 3 arguments and returns container Object" do
         @permission_rights.should be_an_instance_of PermissionRights
       end
   end
   

  describe "#owner" do
     it "Returns name " do
       @permission_rights.owner.should eql "owner"
     end
   end

describe "#ro_group" do
   it "Returns ro_group " do
     @permission_rights.ro_group.should eql "ro_group"
   end
 end

describe "#rw_group" do
   it "Returns rw_group " do
     @permission_rights.rw_group.should eql "rw_group"
   end
 end
 
end
