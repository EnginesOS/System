
require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "../ManagedService.rb"
require_relative "SoftwareService.rb"

class FTPService < SoftwareService
  
  
  def add_consumer_to_service(site_hash)
      return  @core_api.add_ftp_service(site_hash)
     end
  def rm_consumer_from_service (site_hash)
       return  @core_api.rm_ftp_service(site_hash)
    end 
  
   def accepts
     return ["Volume"]      
   end
   
  def get_config_params_descr
     params_descr Hash.new
     params_descr[:setup_form] = get_setup_form
 
     return params_descr
   end
   

  
  def get_setup_form
   form_descr = Hash.new
   form_descr[:title] ="Setup ftp user"
    form_descr[:fields] = get_ftp_fields
      return form_descr
  end
  
  def get_ftp_fields
    fields_descr = Hash.new
    fields_descr["Folder"] =get_folder_fld
    fields_descr["User"] =get_user_fld
    fields_descr["Password"] = get_pass_fld
      return fields_descr
  end
  
  def get_folder_fld
    fld_descr = Hash.new
    fld_descr[:title]="New Folder"
    fld_descr[:tooltip]="New Folder"
    fld_descr[:type]="String"
    fld_descr[:required]=true
    fld_descr[:multi_entry]=true
    fld_descr[:default_value]=""
 
    gfld_descr[:regexverifer]=""
          
  end
 
   def get_user_fld
      fld_descr = Hash.new
      fld_descr[:title]="User"
      fld_descr[:tooltip]="User name"
      fld_descr[:type]="String"
      fld_descr[:required]=true
      fld_descr[:multi_entry]=true
      fld_descr[:default_value]=""
      gfld_descr[:regexverifer]=""
            
    end
 
   def get_pass_fld
      fld_descr = Hash.new
      fld_descr[:title]="Password"
      fld_descr[:tooltip]="Password"
      fld_descr[:type]="String"
      fld_descr[:required]=true
      fld_descr[:multi_entry]=true
      fld_descr[:default_value]=""
      gfld_descr[:regexverifer]=""
            
    end
   
end 