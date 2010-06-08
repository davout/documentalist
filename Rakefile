require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('documentalist', '0.1.0') do |p|
  p.description     = "Ruby interface that talks to OpenOffice"
  p.url             = "http://github.com/davout/documentalist"
  p.author          = "David FRANCOIS"
  p.email           = "david.francois@webflows.fr"
  p.ignore_pattern  = ["tmp/*", "script/*"]
  p.test_pattern    = "test/**/*.rb"
  p.development_dependencies = []
  p.runtime_dependencies = ['zip >=2.0.2']
end  

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }