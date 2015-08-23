require_relative '../ManagedContainer'

require 'spec_helper'

describe ManagedContainer do

  before :each do
    yam_file_name="spec/testdata/managedcontainer.yaml"
    if File.exists?(yam_file_name) == false
      puts("No such configuration:" + yam_file_name )
    end

    yaml_file = File.open(yam_file_name)
    @managedContainer =  ManagedContainer.from_yaml(yaml_file)
    # @managedContainer = ManagedContainer.new("32","ContainerName","hostname","domainname","image",Array.new,Array.new,Array.new,"framework","runtime",Array.new,"setState",80,"repo")
  end

  describe "#new" do
    it "takes 14 arguments and returns ManagedContainer Object" do
      @managedContainer.should be_an_instance_of ManagedContainer
    end
  end

  describe "#read_state()" do  # no api needs to fail nicely
    it "Reads the running state of a ManagedContainer" do
      @managedContainer.read_state.should eql "nocontainer"
      @managedContainer.last_error.should eql "No connection to Engines OS System Warning State Mismatch set to setState but in nocontainer state"
    end
  end
  describe "#inspect_container()" do  # no api needs to fail nicely
     it "Reads inspect_container from ManagedContainer" do
       @managedContainer.inspect_container.should eql false
       @managedContainer.last_error.should eql "No connection to Engines OS System"
     end
   end
  

   describe "#save_state()" do  # no api needs to fail nicely
      it "save_state ManagedContainer" do
        @managedContainer.save_state.should eql false
        @managedContainer.last_error.should eql "No connection to Engines OS System"
      end
    end
    
    describe "#logs_container()" do  # no api needs to fail nicely
    it "Reads logs from ManagedContainer" do
      @managedContainer.logs_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end
  describe "#stop_container()" do  # no api needs to fail nicely
      it "stop ManagedContainer" do
        @managedContainer.stop_container.should eql false
        @managedContainer.last_error.should eql "No connection to Engines OS System"
      end
    end
  describe "#start_container()" do  # no api needs to fail nicely
      it "start ManagedContainer" do
        @managedContainer.start_container.should eql false
        @managedContainer.last_error.should eql "No connection to Engines OS System"
      end
    end
  describe "#restart_container()" do  # no api needs to fail nicely
      it "restart ManagedContainer" do
        @managedContainer.restart_container.should eql false
        @managedContainer.last_error.should eql "No connection to Engines OS System"
      end
    end  
  describe "#register_dns()" do  # no api needs to fail nicely
        it "register_dns ManagedContainer" do
          @managedContainer.register_dns.should eql false
          @managedContainer.last_error.should eql "No connection to Engines OS System"
        end
      end  
  describe "#deregister_dns()" do  # no api needs to fail nicely
         it "deregister_dns ManagedContainer" do
           @managedContainer.deregister_dns.should eql false
           @managedContainer.last_error.should eql "No connection to Engines OS System"
         end
       end  
  describe "#get_ip_str()" do  # no api needs to fail nicely
         it "get_ip_str ManagedContainer" do
           @managedContainer.get_ip_str.should eql false
           @managedContainer.last_error.should eql "No connection to Engines OS System"
         end
       end       
  describe "#register()" do  # no api needs to fail nicely
           it "register ManagedContainer" do
             @managedContainer.register.should eql false
             @managedContainer.last_error.should eql "No connection to Engines OS System"
           end
         end       
  describe "#stats()" do  # no api needs to fail nicely
             it "stats ManagedContainer" do
               @managedContainer.stats.should eql false
               @managedContainer.last_error.should eql "No connection to Engines OS System"
             end
           end       
  
   
        
  describe "#monitor_site()" do  # no api needs to fail nicely
        it "monitor_site ManagedContainer" do
          @managedContainer.monitor_site.should eql false
          @managedContainer.last_error.should eql "No connection to Engines OS System"
        end
      end       
  describe "#demonitor_site()" do  # no api needs to fail nicely
         it "demonitor_site ManagedContainer" do
           @managedContainer.demonitor_site.should eql false
           @managedContainer.last_error.should eql "No connection to Engines OS System"
         end
       end       
           
  describe "#register_site()" do  # no api needs to fail nicely
       it "register_site ManagedContainer" do
         @managedContainer.register_site.should eql false
         @managedContainer.last_error.should eql "No connection to Engines OS System"
       end
     end   
  describe "#deregister_site()" do  # no api needs to fail nicely
         it "deregister_site ManagedContainer" do
           @managedContainer.deregister_site.should eql false
           @managedContainer.last_error.should eql "No connection to Engines OS System"
         end
       end     
  describe "#ps_container()" do  # no api needs to fail nicely
    it "Reads the running process list of a ManagedContainer" do
      @managedContainer.ps_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end

  describe "#delete_image()" do  # no api needs to fail nicely
    it "deletes the image of ManagedContainer" do
      @managedContainer.delete_image.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end
  describe "#destroy_container()" do  # no api needs to fail nicely
    it "destroys the container of ManagedContainer" do
      @managedContainer.destroy_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end
  describe "#create_container()" do  # no api needs to fail nicely
    it "creates the container of ManagedContainer" do
      @managedContainer.create_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end
  describe "#recreate_container()" do  # no api needs to fail nicely
    it "recreate_container the container of ManagedContainer" do
      @managedContainer.recreate_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end

  describe "#unpause_container()" do  # no api needs to fail nicely
    it "unpause_container the container of ManagedContainer" do
      @managedContainer.unpause_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end
  describe "#pause_container()" do  # no api needs to fail nicely
    it "pause_container the container of ManagedContainer" do
      @managedContainer.pause_container.should eql false
      @managedContainer.last_error.should eql "No connection to Engines OS System"
    end
  end

  describe "#set_docker_api" do
    it "sets Docker Api" do
      dockerApi= Docker.new()
      @managedContainer.set_docker_api dockerApi
      @managedContainer.docker_api.should eql dockerApi
    end
  end

  describe "#from_yaml" do
    it "Loads   from_yaml " do
      yam_file_name="spec/testdata/managedcontainer.yaml"
      if File.exists?(yam_file_name) == false
        puts("No such configuration:" + yam_file_name )

      end

      yaml_file = File.open(yam_file_name)
      @managedContainer =  ManagedContainer.from_yaml(yaml_file)
      @managedContainer.should be_an_instance_of ManagedContainer
    end
  end

  describe "#set_last_result" do
    it "sets  set_last_result " do
      @managedContainer.set_last_result "last_result"
      @managedContainer.last_result.should eql "last_result"
    end
  end
  describe "#set_last_error" do
    it "sets  set_last_error " do
      @managedContainer.set_last_error "last_error"
      @managedContainer.last_error.should eql "last_error"
    end
  end
  describe "#conf_register_dns" do
    it "Returns conf_register_dns " do
      @managedContainer.conf_register_dns.should eql true
    end
  end

  describe "#conf_register_site" do
    it "Returns conf_register_site " do
      @managedContainer.conf_register_site.should eql true
    end
  end
  describe "#conf_monitor_site" do
    it "Returns conf_monitor_site " do
      @managedContainer.conf_monitor_site.should eql true
    end
  end

  describe "#conf_monitor_site" do
    it "Returns conf_monitor_site " do
      @managedContainer.conf_monitor_site.should eql true
    end
  end

  describe "#conf_self_start" do
    it "Returns conf_self_start " do
      @managedContainer.conf_self_start.should eql true
    end
  end
  describe "#conf_self_start" do
    it "Returns conf_self_start " do
      @managedContainer.conf_self_start.should eql true
    end
  end
  describe "#conf_self_start" do
    it "Returns conf_self_start " do
      @managedContainer.conf_self_start.should eql true
    end
  end
  describe "#framework" do
    it "Returns framework " do
      @managedContainer.framework.should eql "framework"
    end
  end
  describe "#runtime" do
    it "Returns runtime " do
      @managedContainer.runtime.should eql "runtime"
    end
  end
  describe "#monitored" do
    it "Returns monitored " do
      @managedContainer.monitored.should eql true
    end
  end
  describe "#databases" do
    it "Returns databases " do
      @managedContainer.databases.should be_an_instance_of Array
      @managedContainer.databases[0].should be_an_instance_of DatabaseService
    end
  end
  describe "#setState" do
    it "Returns setstate " do
      @managedContainer.setState.should eql "setState"
    end
  end
  describe "#port" do
    it "Returns port " do
      @managedContainer.port.should eql 80
    end
  end

  describe "#repo" do
    it "Returns repo " do
      @managedContainer.repo.should eql "repo"
    end
  end

  describe "#last_error" do
    it "Returns last_error " do
      @managedContainer.last_error.should eql "None"
    end
  end
  #from Container

  describe "#memory" do
    it "Returns memory " do
      @managedContainer.memory.should eql "32"
    end
  end

  describe "#containerName" do
    it "Returns containerName " do
      @managedContainer.containerName.should eql "ContainerName"
    end
  end

  describe "#hostName" do
    it "Returns hostName " do
      @managedContainer.hostName.should eql "hostname"
    end
  end
  describe "#managedContainerName" do
    it "Returns managedContainerName " do
      @managedContainer.containerName.should eql "ContainerName"
    end
  end
  describe "#domainName" do
    it "Returns domainName " do
      @managedContainer.domainName.should eql "domainname.org"
    end
  end

  describe "#fqdn" do
    it "Returns fqdn " do
      @managedContainer.fqdn.should eql "hostname.domainname.org"
    end
  end

  describe "#image" do
    it "Returns image " do
      @managedContainer.image.should eql "image"
    end
  end
  describe "#eports" do
    it "Returns eports " do
      @managedContainer.eports.should be_an_instance_of Array
      @managedContainer.eports[0].should be_an_instance_of WorkPort
    end
  end
  describe "#volumes" do
    it "Returns volumes " do
      @managedContainer.volumes.should be_an_instance_of Array
      @managedContainer.volumes[0].should be_an_instance_of Volume
    end
  end

  describe "#environments" do
    it "Returns environments " do
      @managedContainer.environments.should be_an_instance_of Array
      @managedContainer.environments[0].should be_an_instance_of EnvironmentVariable
    end
  end

end