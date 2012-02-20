require "#{Dir.pwd}/lib/config/configuration.rb"
Config::Configuration.reload('localhost')
puts "Starting with configuration:"
puts Config::Configuration.get_root('localhost').inspect
