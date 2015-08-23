#class SoftwareService < ManagedService
#  attr_reader :accepts,:author,:title,:description,:container,:consumer_params,:setup_params
#  def get_service_descriptor
#
#    #Author
#    #date
#    #siganturie
#    #title
#    #desciription
#    #etc
#
#    return Hash.new
#  end
#
#  def will_accept?(object)
#    if(object.instanceof?(Volume))
#      return true
#    end
#    return false
#  end
#
#  def accepts
#    return ["Volume","Engine","Database",'WorkPort']
#
#  end
#
#  def get_setup_params_descr
#    #return Hash of params in format key=name, value = type
#    #for Example drop box
#    # hash would include username url and password
#    return Hash.new
#  end
#
#  def get_setup_params
#
#    #returns the params set
#  end
#
#  def get_runtime_params
#
#    #returns the current set
#  end
#
#  def get_runtime_params_descr
#    params_descr Hash.new
#    params_descr["setup"] =  get_setup_form
#    params_descr[:addfolder] = get_folder_form_description
#    params_descr[:adddropuser] = get_dropboxuser_form_description
#    params_descr[:configuredropbox] = get_configuredropbox_form_description
#
#    #using above example of a dropbox
#    #folders to sync
#    return Hash.new
#  end
#
#  protected
#
#  def get_setup_form
#    form_descr = Hash.new
#    form_descr[:title] ="Setup ftp user"
#    form_descr[:fields] = get_ftp_fields
#    return form_descr
#  end
#
#  def get_folder_fields
#    fields_descr = Hash.new
#    fields_descr["Folder"] =get_folder_fld
#    fields_descr["User"] =get_user_fld
#    fields_descr["Password"] = get_pass_fld
#  end
#
#  def get_folder_fld
#    fld_descr = Hash.new
#    fld_descr[:title]="New Folder"
#    fld_descr[:tooltip]="New Folder"
#    fld_descr[:type]="String"
#    fld_descr[:required]=true
#    fld_descr[:multi_entry]=true
#    fld_descr[:default_value]=""
#    fld_descr[:whatever_works_for_lachlan]
#    gfld_descr[:regexverifer]
#
#  end
#
#  def get_bgcolor_fld
#    fld_descr = Hash.new
#    fld_descr[:title]="Background Colour"
#    fld_descr[:tooltip]="Background Colour"
#    fld_descr[:type]="select"
#    fld_descr[:required]=true
#    fld_descr[:multi_entry]=false #is field repeatable
#    fld_descr[:collection]={green=>Green,red=>Red,blue=>Blue} #only present in multi option field items
#    fld_descr[:default_value]="green"
#    fdl_descr[:regexverifer]=nil
#
#  end
#
#end