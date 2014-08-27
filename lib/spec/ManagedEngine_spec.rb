
require_relative '../ManagedEngine'
require_relative '../DatabaseService'
require_relative '../VolumeService'
require_relative '../EnvironmentVariable'
require_relative '../WorkPort'

require 'yaml'
require 'spec_helper'

describe ManagedEngine do
  before :each do
    volumes = Array.new
    permissions = PermissionRights.new("owner","ro_group","rw_group")
    volume = Volume.new("name","localpath","remotepath","rw",permissions)
    volumes.push volume
    eport = WorkPort.new("name",88,88,true)
    eports = Array.new
    eports.push(eport)
    db = Database.new("name","host","user","pass","flavor")
    dbs = Array.new
    dbs.push( db)
    environments = Array.new
    env = EnvironmentVariable.new("name","value",true)
    environments.push env
    @engine = ManagedEngine.new( "name",32,"hostname","domain_name","image",volumes,88,eports,"repo",dbs,environments,"framework","runtime")
    serialized_object = YAML::dump(@engine)
         statefile="spec/testdata/ManagedEngine.yaml"
                     
                   f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                   f.puts(serialized_object)
                   f.close
         f = File.new(statefile,"r")
    @engine = ManagedEngine.from_yaml(f,nil)
  end
  
  describe "#new" do
       it "takes 13 arguments and returns workport Object" do
         @engine.should be_an_instance_of ManagedEngine
       end
   end
   
  describe "#ctype" do
      it "Returns ctype " do
        @engine.ctype.should eql "container"
      end
    end

    

describe "#from_yaml" do
    it "Returns from_yaml " do
      serialized_object = YAML::dump(@engine)
      statefile="spec/testdata/ManagedEngine.yaml"
                  
                f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                f.puts(serialized_object)
                f.close
      f = File.new(statefile,"r")
      ManagedEngine.from_yaml(f,nil).should be_an_instance_of ManagedEngine
    end
  end
end



  