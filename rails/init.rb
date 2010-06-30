require 'yaml'

require File.join(File.dirname(__FILE__), %w{initialize_configuration})
require File.join(File.dirname(__FILE__), %w{.. lib documentalist})

# Load configuration from Rails.root/config/documentalist.yml
Documentalist.config_from_yaml! File.join(RAILS_ROOT, %w{config documentalist.yml}), :section => RAILS_ENV