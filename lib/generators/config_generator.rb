require 'rails'
require 'rails/generators'

module Documentalist
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Create Documentalist config and initilizer files"

    def copy_files
      copy_file 'documentalist.yml', 'config/documentalist.yml'
    end

  end
end