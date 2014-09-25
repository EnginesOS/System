#!/usr/local/rvm/rubies/ruby-2.1.1/bin/ruby
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engos/lib/ruby/ManagedEngine.rb"
require "/opt/engos/lib/ruby/VolumeService.rb"

require "/opt/engos/lib/ruby/SysConfig.rb"
require "rubygems"
require "git"
require 'fileutils'
require 'json'

class EngineBuilder
  @repoName=nil
  @hostName=nil
  @domainName=nil
  @buildname=nil
  @bluePrint=Hash.new
  @framework=nil
  @workerPorts=Array.new
  @webPort=80
  @vols=Array.new
  @environments=Array.new
  @runtime=String.new
  @databases= Array.new
  
  def initialize(repo,host,domain,env,docker_api)
    @hostName=host
    @domainName=domain
    @repoName=repo
    @buildname = File.basename(repo)
    @workerPorts=Array.new
    @webPort=80
    @vols=Array.new
    @environments=Array.new(2)
    @runtime=String.new
    @databases= Array.new
    @docker_api = docker_api
  end

  def backup_lastbuild
    dir=get_basedir

    if Dir.exists?(dir)
      backup=dir + ".backup"
      if Dir.exists?(backup)
        FileUtils.rm_rf backup
      end
      FileUtils.mv(dir,backup)
    end
  end

  def bluePrint
    return @bluePrint
  end

  def buildname
    return @buildname
  end

  def add_custom_env
    envs = @bluePrint["software"]["environment_variables"]
    envivronment = String.new
    ef = File.open( get_basedir + "/home/app.env","w")
    envs.each do |env|
      name=env["name"]
      value=env["value"]
      ask=env["ask_at_runtime"]
      @environments.push(EnvironmentVariable.new(name,value,ask))
      if ask== false
        ef.puts(name + "=\"" + value +"\"")
        #FIXME
        #else
        #ask
      end
    end
    ef.close
  end

  def load_blueprint

    blueprint_file_name= get_basedir + "/blueprint.json"
    blueprint_file = File.open(blueprint_file_name,"r")
    blueprint_json_str = blueprint_file.read
    blueprint_file.close

    @bluePrint = JSON.parse(blueprint_json_str)
  end

  def clone_repo
    g = Git.clone(@repoName, @buildname, :path => SysConfig.DeploymentDir)
  end

  def add_db_service name
    dbname=name #+ "-" + @hostName This - leads to issue with JDBC

    dbf = File.open( get_basedir + "/home/db.env","a+")
    #FIXME need better password and with user set options (perhaps use envionment[dbpass] for this ?
    dbf.puts("dbname=" + dbname)
    dbf.puts("dbhost=" + SysConfig.DBHost)
    dbf.puts("dbuser=" + name)
    dbf.puts("dbpasswd=" + name)

    db = DatabaseService.new(dbname,SysConfig.DBHost,name,name,"mysql")
    @databases.push(db)

    dbf.close
  end

  def create_database_service db
    db_service = EnginesOSapi.loadManagedService("mysql_server", @docker_api)
    if db_service.is_a?(DBManagedService)
      db_service.add_consumer(db)
      return true
    else
      p db_service
      p db_service.result_mesg
      return false
    end
  end

  def add_file_service(name,dest)

    permissions = PermissionRights.new(@hostName,"","")
    vol=Volume.new(name,SysConfig.LocalFSVolHome + "/" + name,dest,"rw",permissions)
    @vols.push(vol)
    fsf = File.open( get_basedir + "/home/fs.env","w")
    fsf.puts("VOLDIR=" + name)
    fsf.puts("CONTFSVolHome=" + vol.remotepath) #not nesscessary the same as dest used in constructor
    fsf.close
  end

  def create_file_service vol
    vol_service = EnginesOSapi.loadManagedService("volmanager", @docker_api)
       if vol_service.is_a?(EnginesOSapiResult) == false
         vol_service.add_consumer(vol)
         return true
       else
         p vol_service
         p vol_service.result_mesg
         return false
       end
    
  end

  def create_workers
    commands = Array.new
    workers =@bluePrint["software"]["worker_commands"]
    workers.each do |worker|
      commands.push(worker["command"])
    end
    if commands.length >0
      cmdf= File.open(get_basedir + "/home/pre-running.sh","w")
      if !cmdf
        puts ("failed to open " + get_basedir + "/home/pre-running.sh")
        exit
      end
      cmdf.chmod(0755)
      cmdf.puts("#!/bin/bash")
      cmdf.puts("cd /home/app")
      commands.each do |command|
        cmdf.puts(command)
      end
      cmdf.close

    end
  end

  def create_work_ports

    ports =  @bluePrint["software"]["work_ports"]
    puts("Ports Json" + ports.to_s)
    if ports != nil
      ports.each do |port|
        portnum = port["port"]
        name = port["name"]
        external = port['external']
        type = port['type']
        if type == nil
          type='tcp'
        end
        #FIX ME when public ports supported
        puts "Port " + portnum.to_s + ":" + external.to_s
        @workerPorts.push(WorkPort.new(name,portnum,external,false,type))
      end
    end

  end

  def copy_templates
    copy_base_faults
    copy_framework_defaults
  end

  def create_presettings_env
    archives = @bluePrint["software"]["installedpackages"]
    n=0
    srcs=String.new
    names=String.new
    locations=String.new
    extracts=String.new
    dirs=String.new

    archives.each do |archive|
      arc_src=archive["src"]
      arc_name=archive["name"]
      arc_loc =archive["dest"]
      arc_extract=archive[ "extractcmd"]
      arc_dir=archive["extractdir"]
      if(n >0)
        srcs = srcs + " "
        names =names + " "
        locations = locations + " "
        extracts =extracts + " "
        dirs =dirs + " "
      end
      srcs = srcs + "\"" + arc_src + "\""
      names = names + "\"" + arc_name + "\""
      locations = locations + "\"" + arc_loc + "\""
      extracts = extracts + "\"" + arc_extract + "\""
      dirs = dirs + "\"" + arc_dir + "\""
      n=n+1
    end

    psf = File.open( get_basedir + "/home/presettings.env","w")
    psf.puts("FRAMEWORK=" + @framework)
    psf.puts("declare -a ARCHIVES=(" + srcs + ")")
    psf.puts("declare -a ARCHIVENAMES=(" + names + ")")
    psf.puts("declare -a ARCHLOCATIONS=(" + locations + ")")
    psf.puts("declare -a ARCHEXTRACTCMDS=(" + extracts + ")")
    psf.puts("declare -a ARCHDIRS=(" + dirs + ")")
    psf.close

  end

  def create_setup_env
    suf = File.open( get_basedir + "/home/setup.env","w")
    confd = @bluePrint["software"]["configuredfile"]
    if confd != nil
      suf.puts("CONFIGURED_FILE=" + confd)
    end
    insted =  @bluePrint["software"]["toconfigurefile"]
    if insted != nil
      suf.puts("INSTALL_SCRIPT=" + insted)
    end

    cjs =  @bluePrint["software"]["cron_jobs"]
    crons = String.new
    n=0
    cjs.each do |cj|
      if n <0
        crons = crons +" "
      end

      crons = crons + "\"" + cj["cronjob"]  + "\""
      n=n+1
    end
    if crons.length >0
      suf.puts("declare -a CRONJOBS=(" + crons + ")")
    end

    pcf = String.new

    pds =   @bluePrint["software"]["persistantdirs"]
    dirs= String.new
    pds.each do |dir|
      path = dir["path"]
      pcf=path
      dirs = dirs + " " + path
    end
    if dirs.length >1
      suf.puts("PERSISTANT_DIRS=\""+dirs+"\"")
    end

    pfs =   @bluePrint["software"]["persistantfiles"]
    files= String.new
    pfs.each do |file|
      path = file["path"]
      pcf=path
      files = files + "\""+ path + "\" "
    end
    if dirs.length >1
      suf.puts("PERSISTANT_FILES="+files)
    end
    if pcf.length >1
      suf.puts("PERSISTANCE_CONFIGURED_FILE=\"" + pcf + "\"")
    end
    seds=@bluePrint["software"]["replacementstrings"]
    sedstrs = String.new
    sedtargets = String.new
    seddsts = String.new
    n=0
    seds.each do |sed|
      if n >0
        sedstrs = sedstrs + " "
        sedtargets = sedtargets + "  "
        seddsts = seddsts + "  "
      end
      sedstrs = sedstrs + "\"" + sed["sedstr"] +"\""
      sedtargets = sedtargets + "\"" +  sed["file"]+"\""
      seddsts = seddsts +  "\"" + sed["dest"]+"\""
      n=n+1
    end
    if  sedstrs.length >1
      suf.puts("declare -a SEDSTRS=(" + sedstrs + ")")
      suf.puts("declare -a SEDTARGETS=(" + sedtargets + ")")
      suf.puts("declare -a SEDDSTS=(" + seddsts + ")")
    end

    suf.close
  end

  def create_stack_env
    stef = File.open(get_basedir + "/home/stack.env","w")
    stef.puts("Memory=" + @bluePrint["software"]["requiredmemory"].to_s)
    stef.puts("Hostname=" + @hostName)
    stef.puts("Domainname=" +  @domainName )
    stef.puts("FRAMEWORK=" + "\"" + @framework +"\"" )
    stef.puts("RUNTIME=" + "\"" + @runtime +"\"" )
    stef.puts("PORT=" + "\"" + @webPort.to_s + "\"" )
    wports = String.new
    n=0
    @workerPorts.each do |port|
      if n < 0
        wports =wports + " "
      end
      wports = wports + port.port.to_s
      n=n+1
    end
    if wports.length >0
      stef.puts("WorkerPorts=" + "\"" + wports +"\"")
    end
    stef.close()
  end

  def create_rake_list
    rake_cmds = @bluePrint["software"]["rake_task"]
    if rake_cmds == nil || rake_cmds.length == 0
      return
    end
    rakefile = File.open( get_basedir + "/home/rakelist")
    rake_cmds.each do |rake_cmd|
      rake_action = rake_cmds["action"]
      p rake_action
      if rake_action !=nil
        rakefile.puts("\"" + rake_action + "\"")
      end

    end
  end

  def build_init
    cmd="cd " + get_basedir + "; docker build  -t " + @hostName + "/init ."
    puts cmd
    res= %x<#{cmd}>
    if $? == false
      puts "build init failed " + res
      return res
    end
    puts res
  end

  def build_setup
    cmd = " docker rm setup " #>&/dev/null "
    puts cmd
    res= %x<#{cmd}>

    cmd = "cd " + get_basedir + "; docker run --memory=128m  -v /opt/dl_cache/:/opt/dl_cache/ --name setup -t " + @hostName +  "/init /bin/bash /home/presetup.sh "
    puts cmd
    res= %x<#{cmd}>
    if $? == false
      puts "build setup failed " +res
      return res
    end
    puts res
  end

  def build_deploy
    cmd="docker commit setup " +  @hostName + "/setup"
    puts cmd
    res= %x<#{cmd}>
    cmd="docker rm setup"
    res= %x<#{cmd}>
    volumes=String.new
    @vols.each do |vol|
      volumes = volumes + " -v " + vol.localpath + "/" + vol.name + ":/" + vol.remotepath + "/" + vol.name
    end
    
    cmd="docker rm deploy"
    res= %x<#{cmd}>
    
    #fixME needs heaps of ram for gcc  (under ubuntu but not debian Why)
    cmd= "cd " + get_basedir + "; docker run --memory=384m --name deploy " + volumes + " -t " +   @hostName + "/setup /bin/bash /home/_init.sh " # su -s /bin/bash www-data /home/configcontainer.sh"
    puts(cmd)
    res= %x<#{cmd}>
    puts res
    if $? == false
      puts "build deploy failed " +res
      return res
    end
   
    
    cmd = "docker commit  deploy " + @hostName + "/deploy"
    res= %x<#{cmd}>
    if $? == false
      puts "build deploy commit failed " +res
      return res
    end
    cmd= "docker rm deploy "
    res= %x<#{cmd}>
    cmd="docker rmi  " + @hostName + "/setup " + @hostName + "/init"
    res= %x<#{cmd}>
  end

  def launch_deploy managed_container
    retval =  managed_container.create_container
    if retval == false
      puts "Failed to Start Container " +  managed_container.last_error
    end
    return retval

  end

  def copy_base_faults
    cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
    system  cmd
  end

  def copy_framework_defaults
    cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" + @framework + "/* "  + get_basedir
    system  cmd
  end

  def add_services
    services=@bluePrint["software"]["softwareservices"]
    services.each do |service|
      servicetype=service["servicetype_name"]
      if servicetype == "mysql"
        dbname = service["name"]
        dest = service["dest"]
        if dest =="local" || dest == nil
          add_db_service  dbname
        end
      else if servicetype=="filesystem"
          fsname = service["name"]
          dest = service["dest"]
          add_file_service(fsname, dest)
        else
          echo "Unknown Service " + servicetype
        end
      end
    end
  end

  def setup_dockerfile
    Dir.mkdir(get_basedir  + "/cron")
    dfile = File.open(get_basedir + "/Dockerfile","a")
    ospackages = @bluePrint["software"]["ospackages"]
    packages=String.new
    ospackages.each do |package|
      packages = packages + package["name"] + " "
    end
    if packages.length >1
      dfile.puts("RUN apt-get install -y " + packages )
    end
    @workerPorts.each do |port|
      dfile.puts("EXPOSE " + port.port.to_s)
    end

    dfile.close

  end

  def getwebport
    stef = File.open( get_basedir + "/home/stack.env","r")
    while line=stef.gets do
      if line.include?("PORT")
        i= line.rindex('=')
        @webport= line.slice(i)
      end
    end
  end

  def read_values
    @framework = @bluePrint["software"]["swframework_name"]
    @runtime =  @bluePrint["software"]["langauge_name"]
    #FIXME need to read from framework and not some piece of static code
    if @framework.include?("rails")
      @webPort=3000
    end
    if @framework.include?("tomcat")
      @webPort=8080
    end
  end

  def get_blueprint_from_repo
    puts("Backup last build")
    backup_lastbuild
    puts("Cloning Blueprint")
    clone_repo
  end

  def build_from_blue_print
    get_blueprint_from_repo
    return build_container
  end

  def build_container

    puts("Reading Blueprint")
    load_blueprint
    puts("Reading Settings")
    read_values
    puts("Copy in default templates")
    copy_templates
    puts("Setting Web port")
    getwebport
    puts("creating Worker port")
    create_work_ports
    puts("Adding services")
    add_services
    puts("Configuring install Environment")
    create_presettings_env
    puts("Configuring Setup Environment")
    create_setup_env
    puts("Configuring Application Environment")
    add_custom_env
    puts("Creating workers")
    create_workers
    puts("Saving stack Environment")
    create_stack_env
    puts("Writing Dockerfile")
    setup_dockerfile
    puts("Building base")
    build_init
    puts("Running Setup")
    build_setup
    puts("Building deploy image")
    build_deploy
    mc = create_managed_container()
    return mc
  end

  def rebuild_managed_container  engine
    @engine  = engine
    backup_lastbuild
    setup_rebuild

    return build_container
  end

  def setup_rebuild
    #mkdir build dir
    Dir.mkdir(get_basedir)
    blueprint = @docker_api.load_blueprint(@engine)
    statefile= get_basedir + "/blueprint.json"
    f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  end

  def create_managed_container

    mc = ManagedEngine.new(@hostName,
    @bluePrint["software"]["requiredmemory"].to_s ,
    @hostName,
    @domainName,
    @hostName + "/deploy",
    @vols,
    @webPort,
    @workerPorts,
    @repoName,
    @databases,
    @environments,
    @framework,
    @runtime,
    @docker_api
    )
    #initialize(name,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime)
    @workerPorts.each do |port|
      puts(port.name + " " + port.port.to_s + ":" + port.external.to_s)
    end

    @databases.each do |db|
      create_database_service db
    end

    @vols.each do |vol|
      create_file_service vol
    end

    if mc.save_blueprint(@bluePrint) == false
      puts "failed to save blueprint " + @bluePrint.to_s
    end

    mc.set_conf_register_site true # needs some intelligence here for worker only

    mc.save_state # no config.yaml throws a no such container so save so others can use
    bp = mc.load_blueprint
    p  bp
    puts("Launching")
    #this will fail as no api at this stage
    if mc.docker_api != nil
      if launch_deploy(mc) == false
        puts "Failed to Launch"
      end
    end
    return mc
  end

  protected

  def get_basedir
    return SysConfig.DeploymentDir + "/" + @buildname
  end

end

