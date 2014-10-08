require 'spec_helper'
require_relative '../EnginesOSapi.rb'

require_relative '../ManagedEngine.rb'

describe EnginesOSapi do
  before :each do
    @enginesapi = EnginesOSapi.new()
  end
  describe "#new" do
          it "takes no arguments and returns Service Object" do            
            @enginesapi.should be_an_instance_of EnginesOSapi
            @enginesapi.docker_api.should be_an_instance_of Docker
          end
      end
      
  describe"#getManagedEngines" do
        it "Returns array of ManagedEngine s " do
          @enginesapi.getManagedEngines.should be_an_instance_of Array
          engines = @enginesapi.getManagedEngines
          engines[0].should be_an_instance_of ManagedEngine
        end
      end
describe"#getManagedServices" do
       it "Returns array of ManagedService s " do
         @enginesapi.getManagedServices.should be_an_instance_of Array
         engines = @enginesapi.getManagedServices
         engines[0].should be_an_instance_of ManagedService
       end
     end
     #FIXME create a test service and retain/move ngix tests
describe"#EnginesOSapi.loadManagedService" do
       it "Returns  ManagedService nginx is used for test " do
          EnginesOSapi.loadManagedService("nginx",@enginesapi.docker_api).should be_an_instance_of NginxService
         
       end
     end 
describe"#getManagedService" do
       it "Returns  ManagedService nginx is used for test " do
         @enginesapi.getManagedService("nginx").should be_an_instance_of NginxService
         
       end
     end 
describe"#getManagedService" do
       it "Returns  ManagedService nginx is used for test " do
         @enginesapi.getManagedService("nginx").should be_an_instance_of NginxService
         
       end
     end 
describe "#loadManagedEngine" do
       it "Returns  ManagedEngine testcontainer is used for test " do
         @enginesapi.loadManagedEngine("testcontainer").should be_an_instance_of ManagedEngine       
       end
     end  

describe "#createEngine" do
       it "Returns  createEngine testcontainer is used for test " do  
         result =  @enginesapi.createEngine("testcontainer")
        result.was_success.should eql true
        engine = @enginesapi.loadManagedEngine("testcontainer")
         @enginesapi.read_state(engine).should eql  "running"
         
       end
     end  
describe "#createEngine" do
       it "Returns  createEngine without a valid container name (does not exsit) is used for test " do  
         result =  @enginesapi.createEngine("nocontainer")
        result.was_success.should eql false
        
       end
     end  
     
describe "#Stop/Start Engine Function tests" do
        it "Tests the Engine Start/Stop functions" do
        result =  @enginesapi.stopEngine("testcontainer")
        result.was_success.should eql true
        
        engine = @enginesapi.loadManagedEngine("testcontainer")
        @enginesapi.read_state(engine).should eql "stopped"
        
        result =  @enginesapi.stopEngine("testcontainer")
        result.was_success.should eql false
          
        result =  @enginesapi.startEngine("testcontainer")
        result.was_success.should eql true 
           
        engine = @enginesapi.loadManagedEngine("testcontainer")
        @enginesapi.read_state(engine).should eql "running"
        
         result =  @enginesapi.startEngine("testcontainer")
         result.was_success.should eql false
         
          result =  @enginesapi.restartEngine("testcontainer")
           result.was_success.should eql true
           
          engine = @enginesapi.loadManagedEngine("testcontainer")
          @enginesapi.read_state(engine).should eql "running"
          
       end
     end
     
describe "#pause/unpause Engine Function tests" do
        it "Tests the Engine Pause/UnPause functions" do
        result =  @enginesapi.pauseEngine("testcontainer")
        result.was_success.should eql true
        
        engine = @enginesapi.loadManagedEngine("testcontainer")
        @enginesapi.read_state(engine).should eql "paused"
        
        result =  @enginesapi.pauseEngine("testcontainer")
        result.was_success.should eql false
          
        result =  @enginesapi.unpauseEngine("testcontainer")
        result.was_success.should eql true 
           
        engine = @enginesapi.loadManagedEngine("testcontainer")
        @enginesapi.read_state(engine).should eql "running"
        
         result =  @enginesapi.unpauseEngine("testcontainer")
         result.was_success.should eql false
          
       end
     end
          
     
describe "#recreate Engine Function tests" do
        it "Tests the Engine recreate functions" do
        result =  @enginesapi.recreateEngine("testcontainer")
        result.was_success.should eql false
        
        result =  @enginesapi.stopEngine("testcontainer")                  
        result =  @enginesapi.recreateEngine("testcontainer")
        result.was_success.should eql true 
           
        engine = @enginesapi.loadManagedEngine("testcontainer")
        @enginesapi.read_state(engine).should eql "running"     
        
          result =  @enginesapi.destroyEngine("testcontainer")
          result.was_success.should eql false
          
          result =  @enginesapi.stopEngine("testcontainer")  
          result.was_success.should eql true 
          result =  @enginesapi.destroyEngine("testcontainer")
          result.was_success.should eql true 
          
          result =  @enginesapi.createEngine("testcontainer")
          engine = @enginesapi.loadManagedEngine("testcontainer")
           @enginesapi.read_state(engine).should eql "running"     
 
       end
     end  

     
describe "#Engine DNS registration tests, " do
        it "Tests the DNS Engine registration" do
          #make sure dns up
          result =  @enginesapi.startService("dns")
          #if dns was down need to register nginx(for time being)
          #By not doing the following we test that restarting dns re registers nginx.engines.local etc
          #@enginesapi.registerEngineDNS("nginx")
                    
          result = @enginesapi.registerEngineDNS("testcontainer")
          result.was_success.should eql true 
          #Fixme check this actually works beyond saying it did
          
          result = @enginesapi.deregisterEngineDNS("testcontainer")          
          result.was_success.should eql true 
            #Fixme check this actually works beyond saying it did
  
          #register is again so next tests can use hostname 
          result = @enginesapi.registerEngineDNS("testcontainer")
        end
end
         
describe "#Engine website registration tests, " do
        it "Tests the website Engine registration" do 
          #Do this prior to de registration of dns
          result = @enginesapi.registerEngineWebSite("testcontainer")
         result.was_success.should eql true 
           #Fixme check this actually works beyond saying it did
          
           
          result = @enginesapi.deregisterEngineWebSite("testcontainer")
          result.was_success.should eql true          
          #Fixme check this actually works beyond saying it did
          end
end
describe "#Engine website monitor tests, " do
        it "Tests the website Engine monitor registration" do 
          result = @enginesapi.monitorEngine("testcontainer")
          result.was_success.should eql true          
          #Fixme check this actually works beyond saying it did
          
          result = @enginesapi.demonitorEngine("testcontainer")
          result.was_success.should eql true          
          #Fixme check this actually works beyond saying it did                  
        end                
     end
     
describe "#Engine registration tests, checking they fail when dns down" do
        it "Tests the Engine registration functions fail when dns down" do
          result =  @enginesapi.stopService("dns")
          
          result = @enginesapi.registerEngineDNS("testcontainer")
          result.was_success.should eql false 
          #Fixme check this actually works beyond saying it did
          
          result = @enginesapi.deregisterEngineDNS("testcontainer")
           result.was_success.should eql false 
          #Fixme check this actually works beyond saying it did
                  
          result = @enginesapi.registerEngineWebSite("testcontainer")
         result.was_success.should eql false 
           #Fixme check this actually works beyond saying it did
           
          result = @enginesapi.deregisterEngineWebSite("testcontainer")
          result.was_success.should eql false          
          #Fixme check this actually works beyond saying it did
          
          result = @enginesapi.monitorEngine("testcontainer")
          result.was_success.should eql false          
          #Fixme check this actually works beyond saying it did
          
          result = @enginesapi.demonitorEngine("testcontainer")
          result.was_success.should eql false          
          #Fixme check this actually works beyond saying it did
          
          
          result =  @enginesapi.startService("dns")
                    
        end                
     end
     
describe "#Test functions when applied to non existant container" do
     it "tests error handling when container by containerName does not exit" do
       result = @enginesapi.loadManagedEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.stopEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.startEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.pauseEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.unpauseEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.destroyEngine("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.deleteEngineImage("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.registerEngineDNS("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.deregisterEngineDNS("nocontainer")
       result.was_success.should eql false
       result = @enginesapi.registerEngineWebSite("nocontainer")
       result.was_success.should eql false
       
     end
end
     
describe "#Test Build from blueprint " do
        it "Test Build from blueprint" do
          
          #clear past tests
          @enginesapi.stopEngine("testhost") 
          @enginesapi.destroyEngine("testhost")
          @enginesapi.deleteEngineImage("testhost")
          
          environment=nil
          @enginesapi.buildEngine("https://github.com/EnginesOS-Blueprints/SimpleInvoices.git","testhost","testdomain.com",environment).should be_instance_of ManagedEngine
          engine = @enginesapi.loadManagedEngine("testhost")
           @enginesapi.read_state(engine).should eql "running"     
          
          bp = @enginesapi.get_engine_blueprint("testhost")
          bp.should be_instance_of Hash
          
           bp = engine.load_blueprint
           bp.should be_instance_of Hash
           
          result =  @enginesapi.stopEngine("testhost")  
         result.was_success.should eql true 
         
         result =  @enginesapi.destroyEngine("testhost")
         result.was_success.should eql true       
            
          result =  @enginesapi.rebuild_engine_container("testhost")
          result.was_success.should eql true 
          
          result =  @enginesapi.stopEngine("testhost")
          result.was_success.should eql true          
          
          result =  @enginesapi.destroyEngine("testhost")

          result =  @enginesapi.deleteEngineImage("testhost")
               result.was_success.should eql true 
        end
end
 end