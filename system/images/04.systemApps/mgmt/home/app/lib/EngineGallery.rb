require 'GalleryMaintainer.rb'
require "/opt/engos/lib/ruby/SysConfig.rb"

require "git"

class EngineGallery
  
  #Galleries are to be drawn in from several sources
  #local  Yaml files  for custom galleries
  #an array of yaml files from a gallery list server for public galleries which are drawn from yaml files on disk

  def gallery_url
    return @gallery_url
  end

  def title
    return @title
  end 
  
  def short_name
    return @short_name
  end
  
  def blueprints_url
    return @blueprints_url
  end
  
  def licence_type
    return @licence_type    
  end
  
  def maintainer
    return @maintainer
  end
  
  def initialize(short_name,title,url,licence,description,maintainer)
      @title = title
      @short_name = short_name
      @blueprints_url = url
      @licence_type = licence #Free | Non Commercial use | Commercial |mixture
      @maintainer =  maintainer
      @gallery_url = local
    end
  
def self.from_yaml( yaml )
      engineGallery = YAML::load( yaml )
      enginegallery
end
    
def EngineGallery.getGallery(gallery_name,gallery_url)
  p gallery_url
  p gallery_name
  
  if gallery_url == "local"
    gallery_config_filename = SysConfig.galleriesDir + "/" + gallery_name + "/gallery.yaml"
      p gallery_config_filename
      return  load(gallery_config_filename)
  end
end

def EngineGallery.load(gallery_file_name)

         if File.exists?(gallery_file_name) == false
           puts("No such configuration:" + gallery_file_name )
           return nil
         end 
         
       gallery_yaml_file = File.open(gallery_file_name) 
       enginegallery = YAML::load( gallery_yaml_file)
      enginegallery
end
     
  def EngineGallery.list_local       
    @galleries = Array.new()
    gallery_dirs = Dir.entries(SysConfig.galleriesDir)
#Fixme should only match yaml files also catch exceptions on bad reads of yaml or file io
    
    gallery_dirs.each do |gallery_dir |
          gallery_file_name = SysConfig.galleriesDir + "/" + gallery_dir + "/gallery.yaml"
          
            if File.exists?(gallery_file_name)            
              gallery = EngineGallery.load(gallery_file_name)
           #   puts gallery_file_name
            #  p gallery
              @galleries.push(gallery)
            end
        end
    return @galleries
    
  end   
  
  
  
def save
         serialized_object = YAML::dump(self)  
         save_serialized(serialized_object)
end
       
def   save_serialized(serialized_object)

        gallery_dir=SysConfig.galleriesDir + "/" + @short_name
             if File.directory?(gallery_dir) ==false
               Dir.mkdir(gallery_dir)
             end
       gallery_config_filename= galleryDir + "/gallery.yaml"            
       gallery_config_file = File.new(gallery_config_file,File::CREAT|File::TRUNC|File::RDWR, 0644)
       gallery_config_file.puts(serialized_object)
       gallery_config_file.close
end


      

  
  def listBluePrints
    blueprints_uri =URI('http://220.233.20.158:3001/json_published_softwares') 
    #blueprints_uri =URI(@blueprints_url)
      Net::HTTP.start(blueprints_uri.host, blueprints_uri.port) do |http|
        blueprints_request = Net::HTTP::Get.new blueprints_uri
    
        blueprints_response = http.request blueprints_request # Net::HTTPResponse object
            if blueprints_response.code.to_i >= 200 && blueprints_response.code.to_i < 400 
              return blueprints_from_jsonstr(blueprints_response.body) 
            else
              return nil #FIXME should put error mesg somewhere
            end    
       end
  end
  
  def blueprints_from_jsonstr blueprints_json_str
    json = JSON.parse(blueprints_json_str)

     return json
   end
  
 
  
  def filter_blueprints types
  end
  
  def get_repository(id)
    blueprint_entry = get_blueprint_entry(id)
    repository = blueprint_entry["repository"]
      return repository
  end
  def get_blueprint(id)
    blueprint_entry = get_blueprint_entry(id)
    p blueprint_entry
    repository = blueprint_entry["repository"]
    short_name = blueprint_entry["short_name"]
      
    buildname = File.basename(repository)
    segments = buildname.split('.')
    buildname = segments[0]
    p short_name
    p repository
    p buildname
    clone_repo(repository,buildname)
    blueprint_filename =  SysConfig.DeploymentDir + "/" + buildname + "/blueprint.json"
    p blueprint_filename
      blueprint_file = File.open(blueprint_filename,"r")
      blueprint_json_str = blueprint_file.read
      blueprint_file.close 

      bluePrint = JSON.parse(blueprint_json_str)
      return bluePrint
  end
  
  protected 
  def get_blueprint_entry(blueprint_id)
    blueprint_uri =URI('http://220.233.20.158:3001/json_published_softwares' + "/" +  blueprint_id) 
    
   # blueprint_uri =URI(@blueprints_url + "/" +  blueprint_id)
           p blueprint_uri 
           p blueprint_uri.host 
           p blueprint_uri.port
         Net::HTTP.start(blueprint_uri.host, blueprint_uri.port) do |http|
           blueprint_request = Net::HTTP::Get.new blueprint_uri
       
           blueprint_response = http.request blueprint_request # Net::HTTPResponse object
               if blueprint_response.code.to_i >= 200 && blueprint_response.code.to_i < 400
                  
                 return blueprints_from_jsonstr(blueprint_response.body) 
               else
                 return nil #FIXME should put error mesg somewhere
               end    
          end
           
  end
  
  def clone_repo(repo, buildname)
   
    p buildname
      backup_lastbuild repo 
           g = Git.clone(repo, buildname, :path => SysConfig.DeploymentDir)
  end

  def backup_lastbuild repo
    
     buildname = File.basename(repo)
     segments = buildname.split('.')   
        buildname = segments[0]
        dir=SysConfig.DeploymentDir + "/" + buildname
     p dir
            if Dir.exists?(dir)
                backup=dir + ".backup"
                  if Dir.exists?(backup)
                    FileUtils.rm_rf backup
                  end
               FileUtils.mv(dir,backup)
            end     
      end


  
end