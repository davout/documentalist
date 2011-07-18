require 'rubygems'
require 'rake'

# We want developers to be able to include rake tasks even without echoe gem available
require 'echoe' rescue nil

if Object.const_defined? :Echoe
  Echoe.new('documentalist', '0.1.4') do |p|
    p.description     = "The smooth document management experience, usable as a Rails gem plugin or standalone in any ruby application"
    p.url             = "http://github.com/davout/documentalist"
    p.author          = "David FRANCOIS"
    p.email           = "david.francois@webflows.fr"
    p.ignore_pattern  = ["tmp/*", "script/*"]
    p.test_pattern    = "test/**/*.rb"
    p.development_dependencies = ['sqlite3-ruby',  'flexmock >=0.8.6']
    p.runtime_dependencies = ['active_support >=3.0.0', 'zip >=2.0.2', 'resque >=1.15.0', 'resque-status >=0.2.3', 'SystemTimer >=1.2']
    p.require_paths = ['resque/job_with_status']
  end
end


