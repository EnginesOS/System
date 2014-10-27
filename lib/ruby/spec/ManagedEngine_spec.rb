
require_relative '../ManagedEngine'

require_relative '../ManagedServices'
require_relative '../EnvironmentVariable'
require_relative '../WorkPort'
require_relative '../EnginesOSapi.rb'

require 'yaml'
require 'spec_helper'

describe ManagedEngine do
  before :each do
    volumes = Array.new
    permissions = PermissionRights.new("owner","ro_group","rw_group")
    volume = Volume.new("test","/opt/engines/","/fs","rw",permissions)
    volumes.push volume
    eport = WorkPort.new("name",888,888,true,"tcp")
    eports = Array.new
    eports.push(eport)
    db = DatabaseService.new("name","host","user","pass","flavor")
    dbs = Array.new
    dbs.push( db)
    environments = Array.new
    env = EnvironmentVariable.new("name","value",true)
    environments.push env
    docker_api = Docker.new
    @engine = ManagedEngine.new("testcontainer",32,"test","test","enginesos/testimage",volumes,88,eports,"none",dbs,environments,"test-framework","test-runtime",docker_api)

    
    
    serialized_object = YAML::dump(@engine)
         statefile="spec/testdata/ManagedEngine.yaml"
                     
                   f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                   f.puts(serialized_object)
                   f.close
         f = File.new(statefile,"r")
    dockerApi= Docker.new()
    @engine = ManagedEngine.from_yaml(f,dockerApi)
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
  describe "#save_state" do
      it "Saves Container State " do
        @engine.save_state.should eql true
        @engine.set_docker_api(nil)
        @engine.save_state.should eql false
    end
  end
  describe "#setState" do
    it "Returns setstate " do
      @engine.setState.should eql "nocontainer"
    end
    
   describe "#docker_api" do
     it "Returns docker_api" do
       @engine.docker_api.should be_an_instance_of Docker
     end     
   end
   

    
   describe "create_pause_unpause_stop_destroy_delete_container" do
    it "Creates the test container " do
      
      #need to remove existing from past failed tests 
      #no issues if these fail 
      #BTW DO NOT delete the test image
      @engine.stop_container
      @engine.destroy_container
      
      @engine.start_container
      @engine.last_error.should eql "Can't Start Container as nocontainer"
      
      @engine.create_container 
      @engine.last_error.should eql nil
      
      p @engine.last_error
      p @engine.last_result
      
      @engine.read_state.should eql "running"
      @engine.last_error.should eql nil
      
      @engine.pause_container.should eql true 
      @engine.pause_container.should eql false
      
      @engine.unpause_container.should eql true
      @engine.unpause_container.should eql false
      
      @engine.stop_container.should eql true
      @engine.stop_container.should eql false
      
      @engine.start_container.should eql true
      @engine.start_container.should eql false
      
      @engine.stop_container.should eql true
      @engine.destroy_container.should eql true
      
      @engine.start_container.should eql false
      
      
     # do not test until testing built from blueprint @engine.delete_image.should eql true
     end
   end
      
  end
  
end



  