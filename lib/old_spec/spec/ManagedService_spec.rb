require_relative '../ManagedServices'
require 'spec_helper'

describe ManagedService do
  before :each do
    volumes = Array.new
       permissions = PermissionRights.new("owner","ro_group","rw_group")
       volume = Volume.new("name","localpath","remotepath","rw",permissions)
       volumes.push volume
       eport = WorkPort.new("name",88,88,true,"proto")
       eports = Array.new
       eports.push(eport)
       environments = Array.new
    db = DatabaseService.new("name","host","user","pass","flavor")
      dbs = Array.new
      dbs.push( db)
       env = EnvironmentVariable.new("name","value",true)
       environments.push env
    @managed_service = ManagedService.new("ContainerName",32,"hostname","domainname","image",volumes,80,eports,dbs,environments,"framework","runtime")
    serialized_object = YAML::dump(@managed_service)
          statefile="spec/testdata/ManagedService.yaml"
                      
                    f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                    f.puts(serialized_object)
                    f.close
          f = File.new(statefile,"r")
     @managed_service = ManagedService.from_yaml(f,nil)           
  end
  
  describe "#new" do
      it "takes 12 arguments and returns container Object" do
        @managed_service.should be_an_instance_of ManagedService
      end
  end
  
  describe "#consumers" do
     it "Returns consumers " do
       @managed_service.consumers.should be_an_instance_of Hash
     end
   end
    
  describe "#create_service" do
     it "Returns create_service " do
       @managed_service.create_service.should eql false
     end
   end
  describe "#destroy" do
       it "Returns destroy " do
         @managed_service.destroy.should eql false
       end
     end
  describe "#deleteimage" do
       it "Returns deleteimage " do
         @managed_service.deleteimage.should eql false
       end
     end
  describe "#create_service" do
       it "Returns create_service " do
         @managed_service.create_service.should eql false
       end
     end
     
     #do I need to duplicate these?
 describe "#memory" do
   it "Returns memory " do
     @managed_service.memory.should eql 32
   end
 end
  describe "#containerName" do
     it "Returns containerName " do
       @managed_service.containerName.should eql "ContainerName"
     end
   end
   
   describe "#hostName" do
     it "Returns hostName " do
       @managed_service.hostName.should eql "hostname"
     end
   end
  
   describe "#domainName" do
     it "Returns domainName " do
       @managed_service.domainName.should eql "domainname"
     end
   end
   
   describe "#fqdn" do
     it "Returns fqdn " do
       @managed_service.fqdn.should eql "hostname.domainname"
     end
   end
   
   describe "#image" do
     it "Returns image " do
       @managed_service.image.should eql "image"
     end
   end
   describe "#eports" do
     it "Returns eports " do
       @managed_service.eports.should be_an_instance_of Array
       @managed_service.eports[0].should be_an_instance_of WorkPort
     end
   end
   describe "#volumes" do
     it "Returns volumes " do
       @managed_service.volumes.should be_an_instance_of Array
       @managed_service.volumes[0].should be_an_instance_of Volume
     end
   end
   describe "#environments" do
     it "Returns environments " do
       @managed_service.environments.should be_an_instance_of Array
       @managed_service.environments[0].should be_an_instance_of EnvironmentVariable
     end
   end
   
end