require 'documentalist'
require 'rails'

module Documentalist
  class Railtie < ::Rails::Railtie

    generators do
      require 'generators/config_generator'
    end

    rake_tasks do
      load "tasks/documentalist.rake"
    end

    config.before_initialize do
      if File.exist? ::Rails.root.join('config/documentalist.yml')
        Documentalist.init(::Rails.root, 'config/documentalist.yml', ::Rails.env)
      end
    end

  end
end
