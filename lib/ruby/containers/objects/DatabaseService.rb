#require_relative 'StaticService.rb'
#
#class DatabaseService < StaticService
#
#  def initialize(parent,name,host,user,pass,flavor)
#     @serviceType="database"
#     @flavor = flavor #mysql pgsql AWS_rdms etc
#     @dbHost = host
#     @dbUser = user
#     @dbPass = pass
#     @name = name
#     @owner = parent
#   end
#   
#  attr_reader :owner,:dbHost,:dbUser,:dbPass,:flavor,:name
# 
#   
#  def add_backup_src_to_hash backup_hash
#     backup_hash[:source_type] = flavor
#     backup_hash[:source_name] = name
#     backup_hash[:source_host] =  dbHost
#     backup_hash[:source_user] = dbUser
#     backup_hash[:source_pass] = dbPass
#             
#   end
#end