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
  
  def read_scripts
    return unless @blueprint[:software].key?(:scripts)
    @custom_start_script =  @blueprint[:software][:scripts][:start].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:start)
    @custom_stop_script =  @blueprint[:software][:scripts][:shutdown].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:shutdown)
    @custom_install_script =  @blueprint[:software][:install].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:install)
    @custom_post_install_script =  @blueprint[:software][:scripts][:post_install].gsub(/\r/, '') if  @blueprint[:software][:scripts].key?(:post_install)
  end
   
end