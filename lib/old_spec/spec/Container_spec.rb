require_relative '../Container'
require 'spec_helper'

describe Container do
  before :each do
    volumes = Array.new
       permissions = PermissionRights.new("owner","ro_group","rw_group")
       volume = Volume.new("name","localpath","remotepath","rw",permissions)
       volumes.push volume
       eport = WorkPort.new("name",88,88,true,"proto")
       eports = Array.new
       eports.push(eport)
       db = DatabaseService.new("name","host","user","pass","flavor")
       dbs = Array.new
       dbs.push( db)
       environments = Array.new
       env = EnvironmentVariable.new("name","value",true)
       environments.push env
    @container = Container.new( "32","ContainerName","hostname","domainname","image",eports,volumes,environments)      
  end
  
  describe "#new" do
      it "takes 8 arguments and returns container Object" do
        @container.should be_an_instance_of Container
      end
  end
  
 describe "#memory" do
   it "Returns memory " do
     @container.memory.should eql "32"
   end
 end
 
  describe "#containerName" do
    it "Returns containerName " do
      @container.containerName.should eql "ContainerName"
    end
  end
  
  describe "#hostName" do
    it "Returns hostName " do
      @container.hostName.should eql "hostname"
    end
  end
  describe "#containerName" do
    it "Returns containerName " do
      @container.containerName.should eql "ContainerName"
    end
  end
  describe "#domainName" do
    it "Returns domainName " do
      @container.domainName.should eql "domainname"
    end
  end
  
  describe "#fqdn" do
    it "Returns fqdn " do
      @container.fqdn.should eql "hostname.domainname"
    end
  end
  
  describe "#image" do
    it "Returns image " do
      @container.image.should eql "image"
    end
  end
  describe "#eports" do
    it "Returns eports " do
      @container.eports.should be_an_instance_of Array
      @container.eports[0].should be_an_instance_of WorkPort
    end
  end
  describe "#volumes" do
    it "Returns volumes " do
      @container.volumes.should be_an_instance_of Array
      @container.volumes[0].should be_an_instance_of Volume
    end
  end
  describe "#environments" do
    it "Returns environments " do
      @container.environments.should be_an_instance_of Array
      @container.environments[0].should be_an_instance_of EnvironmentVariable
    end
  end
  
 
end