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
     
describe"#getManagedService" do
       it "Returns  ManagedService nginx is used for test " do
          EnginesOSapi.loadManagedService("nginx",@enginesapi.docker_api).should be_an_instance_of ManagedService
         
       end
     end 
 end