
if Process.euid != 21000
  p "This program can only be run be the engines user"
  exit
end

require_relative 'commands/commands.rb'