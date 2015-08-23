require_relative '../ManagedServices/VolumeService.rb'
require_relative '../PermissionRights.rb'
require 'spec_helper'

describe Volume do
  before :each do
    permissions = PermissionRights.new("owner","ro_group","rw_group")
    @volume = Volume.new("name","localpath","remotepath","rw",permissions)    
  end
  
  describe "#new" do
        it "takes 5 arguments and returns Volume Object" do
          @volume.should be_an_instance_of Volume
        end
    end
   describe "#name" do
      it "Returns name " do
        @volume.name.should eql "name"
      end
    end
  describe "#localpath" do
     it "Returns localpath " do
       @volume.localpath.should eql "localpath"
     end
   end
  describe "#remotepath" do
     it "Returns remotepath " do
       @volume.remotepath.should eql "remotepath"
     end
   end
  describe "#mapping_permissions" do
     it "Returns mapping_permissions " do
       @volume.mapping_permissions.should eql "rw"
     end
   end
  describe "#vol_permissions" do
     it "Returns vol_permissions " do
       @volume.vol_permissions.should be_an_instance_of PermissionRights
     end
   end
   
end

  