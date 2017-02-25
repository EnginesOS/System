require_relative '../blueprint_reader.rb'
class VersionedBlueprintReader < BluePrintReader
  def read_lang_fw_values
     log_build_output('Read Framework Settings')
     @framework = @blueprint[:software][:base][:framework]
 
     @runtime = ''
     @memory = @blueprint[:software][:base][:required_memory]
   rescue StandardError => e
     SystemUtils.log_exception(e)
   end
  
  
   
end