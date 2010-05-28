require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('officer', '0.1.0') do |p|
  p.description     = "Ruby interface that talks to OpenOffice"
  p.url             = "http://github.com/davout/officer"
  p.author          = "David FRANCOIS"
  p.email           = "david.francois@webflows.fr"
  p.ignore_pattern  = ["tmp/*", "script/*"]
  p.development_dependencies = []
end  

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }