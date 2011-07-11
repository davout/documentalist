module Documentalist
  class Railtie < ::Rails::Railtie

    generators do
      require 'generators/config_generator'
    end

    rake_tasks do
      load "tasks/documentalist.rake"
    end

    config.after_initialize do
      Documentalist.load_config!(::Rails.env)
      # Require all backends
      Dir.glob(File.join(File.dirname(__FILE__), 'backends', '*.rb')).each do |backend|
        require backend
      end
    end

  end
end
