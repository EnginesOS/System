require 'securerandom' 

class BuilderPublic
  def initialize(builder)
    @builder = builder
  end

  # Build public interface
    def  http_protocol
      @builder.build_params[:http_protocol]
    end
    
    def engine_name
      @builder.build_params[:engine_name]
    end
    
    def memory
      @builder.build_params[:memory]
    end
    
    def hostname
      @builder.build_params[:host_name]
    end
    
    def domain_name
      @builder.build_params[:domain_name]
    end
       
    def repository
      @builder.build_params[:repository_url]
       end
       
    def http_protocol
      @builder.http_protocol # 'http' 'https' 'http_https'
    end

  def fqdn
    hostname + '.' + domain_name
  end


  def web_port
    @builder.web_port
  end

  def build_name
    @builder.build_name
  end

  def runtime
    @builder.runtime
  end

  def set_environments
    @builder.set_environments
  end

  def engine_environment
    @builder.engine_environment
  end

  def blueprint
    @builder.blueprint
  end

  def data_gid
    @builder.data_gid
  end

  def memory
    @builder.build_params[:memory]
  end
end
