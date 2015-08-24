require_relative '../service_definitions/software_service_definition.rb'

#require 'json'
#
#class SoftwareServiceDefinition
#  attr_reader :accepts,
#              :author,
#              :title,
#              :description,
#              :service_name,
#              :consumer_params,
#              :setup_params,
#              :dedicated,
#              :service_type,
#              :publisher_namespace,
#              :service_container,
#              :persistant,
#              :target_environment_variables
#
#
#  def SoftwareServiceDefinition.from_yaml( yaml )
#     begin
#      # p yaml.path
#       serviceDefinition = YAML::load( yaml )
#
#       return serviceDefinition
#     rescue Exception=>e
#       puts e.message + " with " + yaml
#       SystemUtils.log_exception(e)
#
#     end
#  end
#
#  def SoftwareServiceDefinition.find(service_type,provider)
#
##          p :looking_for
##          p provider
##          p service_type
#
#          #FIXME and support more than one dir
#          if service_type.include?('/')
##            p :sub_service
##           # provider += "/" + service_type.sub(/\/.*/,"")
##           #service_type.sub(/.*\//,"")
##
##            p :sub_service
##            p provider
##            p service_type
#
#          end
#    dir = SysConfig.ServiceTemplateDir + "/" + provider
#            p :dir
#            p dir
#          if Dir.exist?(dir)
#            service_def = SoftwareServiceDefinition.load_service_def(dir,service_type)
#              if service_def == nil
#                p :error_got_nil_service_type
#                p service_type
#                p :from
#                p dir
#                return nil
#              end
##              p :service_def
##              p service_def.title
##              p service_def.to_s
#              return service_def.to_h
#          end
#    rescue Exception=>e
#
#        SystemUtils.log_exception(e)
#
#  end
#
#  def SoftwareServiceDefinition.load_service_def(dir,service_type)
#    filename=dir + "/" + service_type + ".yaml"
#      p :loading_def_from
#      p filename
#    if File.exist?(filename)
#      yaml = File.read(filename)
#
#      return SoftwareServiceDefinition.from_yaml(yaml)
#    end
#    p :no_such_service_definitition_file
#    return nil
#    rescue Exception=>e
#           SystemUtils.log_exception(e)
#  end
#
#  def search_dir(dir,service_type)
#    return SoftwareServiceDefinition.search_dir(dir,service_type)
#  end
#
#  def SoftwareServiceDefinition.search_dir(dir,service_type)
#    root = dir
#    if Dir.exists?(dir)
#      Dir.foreach(dir) do |service_dir_entry|
#        if Dir.exist?(service_dir_entry) == true && service_dir_entry.start_with?(".") ==false
#          search_dir(root + "/" + service_dir_entry,service_type)
#        else
#          if File.exist?(root + "/" + service_dir_entry + "/" + service_type + ".yaml" )
#            return load(dir,service_type)
#          end
#        end
#      end
#    end
#    rescue Exception=>e
#
#           SystemUtils.log_exception(e)
#  end
#
#
#
#  def to_h
#       hash = {}
#       instance_variables.each {|var|
#         symbol = var.to_s.delete("@").to_sym
#         p symbol
#         hash[symbol] = instance_variable_get(var) }
#
#         return SystemUtils.symbolize_keys(hash)
##     end
##    p self.to_s
##    jason = self.to_json
##    p :jason
##    p jason.to_s
##    return JSON.parse(jason, {:symbolize_names => true})
#    rescue Exception=>e
#
#           SystemUtils.log_exception(e)
#  end
#end