require 'yaml'

require File.join(File.dirname(__FILE__), %w{initialize_configuration})
require File.join(File.dirname(__FILE__), %w{.. init})

# Load configuration from Rails.root/config/documentalist.yml
Documentalist.config_from_yaml! File.join(RAILS_ROOT, %w{config documentalist.yml}), :section => RAILS_ENV

# Set a default for the logfile if it hasn't been provided by the configuration file
unless Documentalist.config[:log_file]
  Documentalist.config[:log_file] = File.join(RAILS_ROOT, "log", "documentalist-#{RAILS_ENV}.log")
end