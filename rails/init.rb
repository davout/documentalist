require 'yaml'

require File.join(File.dirname(__FILE__), %w{initialize_configuration})
require File.join(File.dirname(__FILE__), %w{.. lib documentalist})

# Load configuration from Rails.root/config/documentalist.yml
Documentalist.config = YAML::load(File.open(File.join(RAILS_ROOT, %w{config documentalist.yml})))[RAILS_ENV]
