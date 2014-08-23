class WorkPort
  def initialize(name,num,external,publicport)
    @name=name
    @port=num
    @external=external
    @publicFacing=publicport
  end
  def name
    return @name
  end
  
  def port
    return @port
  end
  
  def external
    @external    
  end
  
  def publicFacing
    return @publicFacing
  end  
end

class EnvironmentVariable
  def initialize(name,value,setatrun)
    @name=name
    @value=value
    @setatrun=setatrun
  end
  def setatrun
    return @setatrun
  end
  def name
    return @name
  end
  def value
    return @value
  end
end


class Service
  def initialize(type)
    @serviceType=type
  end
end


class Database < Service
  @serviceType="db"
  def initialize(name,host,user,pass,flavor)
     Service.initialize("database")
     @flavor = flavor #mysql pgsql AWS_rdms etc
     @dbHost = host
     @dbUser = user
     @dbPass = pass
     @name = name
   end
end



class Volume < Service #Latter will include group and perhaps other attributes
   @serviceType="fs"
   @localpath=SysConfig.LocalFSVolHome
   @remotepath=SysConfig.CONTFSVolHome
   @permissions="rw"
   
  def initialize(name,localpath,remotepath)
    @name = name
           if remotepath !=nil        
             @remotepath=remotepath
           else
             @remotepath=SysConfig.CONTFSVolHome
           end
           if localpath !=nil        
             @localpath=localpath
           else
             @localpath=SysConfig.LocalFSVolHome
           end
    @permissions="rw"   
  end
  
  def initialize(name,localpath,remotepath,permissions)
      @name = name
        if remotepath !=nil        
          @remotepath=remotepath
        else
          @remotepath=SysConfig.CONTFSVolHome
        end
        if localpath !=nil        
          @localpath=localpath
        else
          @localpath=SysConfig.LocalFSVolHome
        end
      @permissions=permissions
    end
    
  def permissions
    @permissions
  end
  
  def name
    return @name
  end
  def remotepath
    return @remotepath
  end
  def localpath
    return @localpath
  end
  def user
    return @user    
  end
  
  def group
    return @group
  end
end
